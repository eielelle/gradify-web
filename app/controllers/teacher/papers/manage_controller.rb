# frozen_string_literal: true

module Teacher
  module Papers
    class ManageController < Teacher::LayoutController
      before_action :authenticate_user!

      def index
        @teacher = current_user

        @subjects = @teacher.subjects.includes(:school_classes) # Fetch the subjects and related school classes

        @assignments = @teacher.school_sections
                               .includes(school_year: { school_class: :subjects })
                               .group_by { |section| section.school_year.school_class.subjects }
      end

      def show
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])
        @exams = @subject.exams.includes(:subject)
      end

      def exam_details
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])  # Fetch the specific subject based on the teacher's assignment
        @exam = @subject.exams.find(params[:exam_id])   # Fetch the exam associated with the subject
      
        # Fetch students based on the subject and school section they are assigned to
        @students = User.joins(:school_sections, :subjects)
                        .where(role: 'student')
                        .where(school_sections: { id: @teacher.school_section_ids }) # Sections that are taught by this teacher
                        .where(subjects: { id: @subject.id }) # Ensure the subject matches
                        .distinct
      
        # Preload all responses for the exam to avoid N+1 queries
        @responses = Response.where(exam: @exam)
        .where(user_id: @students.pluck(:id))
        .index_by(&:user_id)

        # Calculate statistics for each student
        @student_stats = @students.map do |student|
        response = @responses[student.id]
        stats = calculate_response_stats(response, @exam) if response

        {
        student: student,
        stats: stats || default_stats
        }
        end

        # Handle case where no students are found
        if @students.empty?
          flash.now[:alert] = "No students found for this exam and subject combination."
        end

        # Calculate class-wide item analysis
        @item_analysis = calculate_class_item_analysis
      end

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
          when '?'
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
        when '?' then 'No Answer'
        when '*' then 'Double Answer'
        else 'Incorrect'
        end
      end

      def student_exam_overviews
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])
        @exam = @subject.exams.find(params[:exam_id])
        @student = User.find(params[:student_id])
        
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

      def calculate_class_item_analysis
        return [] unless @exam&.answer_key.present?
      
        # Get all responses for this exam
        responses = Response.where(exam: @exam).includes(:user)
        total_students = responses.count
        
        # Initialize item analysis array
        analysis = []
        
        # Process each question
        @exam.items.times do |item_index|
          # Count responses for each option
          option_counts = {
            'A' => 0, 'B' => 0, 'C' => 0, 'D' => 0,
            '?' => 0, # No answer
            '*' => 0  # Double answer
          }
          
          # Count responses for this item
          responses.each do |response|
            next unless response.answer.present?
            answer = response.answer[item_index]
            option_counts[answer] = option_counts[answer].to_i + 1
          end
          
          # Get correct answer for this item
          correct_answer = @exam.answer_key[item_index]
          
          # Calculate frequencies
          correct_freq = option_counts[correct_answer].to_i
          incorrect_freq = total_students - correct_freq - option_counts['_'].to_i - option_counts['*'].to_i
          
          # Calculate difficulty index (p-value)
          difficulty_index = total_students > 0 ? (correct_freq.to_f / total_students).round(2) : 0
          
          # Calculate discrimination index
          discrimination_index = calculate_class_discrimination_index(responses, item_index, correct_answer)
          
          analysis << {
            item_number: item_index + 1,
            answer_key: correct_answer,
            options: option_counts,
            correct_frequency: correct_freq,
            incorrect_frequency: incorrect_freq,
            difficulty_index: difficulty_index,
            discrimination_index: discrimination_index
          }
        end
        
        analysis
      end

      def calculate_class_discrimination_index(responses, item_index, correct_answer)
        return 0 if responses.empty?
        
        # Sort responses by total score
        sorted_responses = responses.sort_by { |r| calculate_total_score(r) }
        
        # Take top and bottom 27% (standard practice in item analysis)
        group_size = (responses.count * 0.27).ceil
        upper_group = sorted_responses.last(group_size)
        lower_group = sorted_responses.first(group_size)
        
        # Calculate correct answers in each group
        upper_correct = upper_group.count { |r| r.answer&.chars&.at(item_index) == correct_answer }
        lower_correct = lower_group.count { |r| r.answer&.chars&.at(item_index) == correct_answer }
        
        # Calculate discrimination index
        if group_size > 0
          ((upper_correct - lower_correct).to_f / group_size).round(2)
        else
          0
        end
      end

    end
  end
end
