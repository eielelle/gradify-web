# frozen_string_literal: true

module Student
    module Exams
      class ManageController < Student::LayoutController
        before_action :authenticate_user!
        before_action :redirect_if_default_password
  
        def index
          return if performed?

          @student = current_user
          @subjects_with_exams = @student.subjects.includes(:exams, :school_classes)
          @show_pass_prompt = current_user.password_set_to_default
        end
  
        def show
          @student = current_user
          @exam = Exam.find(params[:id])
          @subject = @exam.subject
  
          # Fetch the student's response for this exam
          @response = Response.find_by(exam: @exam, user: @student)
          
          # Calculate statistics if response exists
          if @response&.answer.present? && @exam.answer_key.present?
            @stats = calculate_response_stats(@response, @exam)
          else
            @stats = default_stats
          end
          
          # Fetch the answer key and student's answers for item analysis
          @answer_key = @exam.answer_key
          @student_answers = @response&.answer

          # Calculate item analysis metrics
          calculate_item_analysis if @response&.answer.present? && @exam.answer_key.present?
        end
  
  
        private

        def calculate_response_stats(response, exam)
          return default_stats unless response&.answer.present? && exam.answer_key.present?
        
          student_answers = response.answer.chars
          correct_answers = exam.answer_key.chars
          items_count = exam.items
        
          # Initialize counters
          correct = 0
          incorrect = 0
          double_answer = 0
          no_answer = 0
        
          # Compare each answer
          student_answers.each_with_index do |student_answer, index|
            break if index >= items_count # Don't process beyond the number of items
            
            case student_answer
            when correct_answers[index]
              correct += 1
            when '_'
              no_answer += 1
            when '*'
              double_answer += 1
            else
              incorrect += 1
            end
          end
        
          {
            total_score: correct,
            correct: correct,
            incorrect: incorrect,
            double_answer: double_answer,
            no_answer: no_answer,
            status: response.detected == 1 ? 'Detected' : 'Undetected'
          }
        end

        def default_stats
          {
            total_score: 0,
            correct: 0,
            incorrect: 0,
            double_answer: 0,
            no_answer: 0,
            status: 'Undetected'
          }
        end
  
        def calculate_item_analysis
          return unless @response&.answer.present? && @exam.answer_key.present?
  
          @item_analysis = []
          student_answers = @response.answer.chars
          correct_answers = @exam.answer_key.chars
  
          # Get all responses for this exam
          all_responses = Response.where(exam: @exam).includes(:user)
          total_students = all_responses.count
  
          correct_answers.each_with_index do |correct_ans, idx|
            # Calculate how many students got this item correct
            correct_count = all_responses.count { |r| r.answer&.chars&.at(idx) == correct_ans }
            
            # Calculate average correct percentage
            avg_correct = total_students > 0 ? (correct_count.to_f / total_students * 100).round(2) : 0
            
            # Calculate difficulty index
            difficulty_index = total_students > 0 ? (correct_count.to_f / total_students).round(2) : 0
            
            # Calculate discrimination index
            discrimination_index = calculate_discrimination_index(all_responses, idx, correct_ans)
  
            @item_analysis << {
              item_number: idx + 1,
              correct_answer: correct_ans,
              student_answer: student_answers[idx],
              status: get_answer_status(student_answers[idx], correct_ans),
              avg_correct: avg_correct,
              difficulty_index: difficulty_index,
              discrimination_index: discrimination_index
            }
          end
        end

        def calculate_discrimination_index(all_responses, item_index, correct_answer)
          return 0 if all_responses.empty?
  
          # Sort responses by total score
          sorted_responses = all_responses.sort_by { |r| calculate_total_score(r) }
          
          # Split into upper and lower groups
          group_size = (all_responses.count / 3.0).ceil
          upper_group = sorted_responses.last(group_size)
          lower_group = sorted_responses.first(group_size)
  
          # Calculate correct answers in each group
          upper_correct = upper_group.count { |r| r.answer&.chars&.at(item_index) == correct_answer }
          lower_correct = lower_group.count { |r| r.answer&.chars&.at(item_index) == correct_answer }
  
          # Calculate discrimination index
          ((upper_correct - lower_correct).to_f / group_size).round(2)
        end

        def calculate_total_score(response)
        return 0 unless response&.answer.present? && response.exam&.answer_key.present?
        
        response.answer.chars.zip(response.exam.answer_key.chars).count { |student, correct| student == correct }
      end

      def get_answer_status(student_answer, correct_answer)
        case student_answer
        when correct_answer then 'Correct'
        when '_' then 'No Answer'
        when '*' then 'Double Answer'
        else 'Incorrect'
        end
      end
  
        def authorize_student
          unless current_user.role == 'student'
            flash[:alert] = "You are not authorized to access this page."
            redirect_to root_path
          end
        end

        def redirect_if_default_password
          if current_user.password_set_to_default == true
            flash[:alert] = "Please change your default password for security purposes."
            redirect_to student_config_path and return
          end
        end
      end
    end
end