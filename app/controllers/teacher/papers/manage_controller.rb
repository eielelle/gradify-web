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

      def student_exam_overviews
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])
        @exam = @subject.exams.find(params[:exam_id])
        @student = User.find(params[:student_id])
        
        # Fetch the answer key from the exam
        @answer_key = @exam.answer_key
        
        # Commented out the fetching of student's answers for now
        # @student_answers = @student.exam_results.where(exam: @exam).pluck(:answers).first
        
        # Initialize arrays to store analysis data
        # @average_correct = []
        # @difficulty_index = []
        # @discrimination_index = []
        
        # Fetch all students who took the exam for future item analysis
        # all_students = @exam.students
        
        # Example of item analysis logic for future use
        # (1..@answer_key.size).each do |item|
        #   total_students = all_students.count
        #   correct_answers = all_students.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
          
        #   # Calculate average correct percentage for this item
        #   @average_correct[item - 1] = (correct_answers.to_f / total_students) * 100
          
        #   # Calculate Difficulty Index
        #   @difficulty_index[item - 1] = correct_answers.to_f / total_students
          
        #   # Split students into upper and lower groups based on scores
        #   upper_group = all_students.sort_by(&:score).last(total_students / 2)
        #   lower_group = all_students.sort_by(&:score).first(total_students / 2)
          
        #   upper_correct = upper_group.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
        #   lower_correct = lower_group.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
          
        #   # Calculate Discrimination Index (upper group correct - lower group correct)
        #   @discrimination_index[item - 1] = (upper_correct - lower_correct).to_f / (total_students / 2)
        # end
      end
      
      

    end
  end
end
