module Student
  module Grades
    class ManageController < Student::LayoutController
      before_action :authenticate_user!
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(Exam, params)

        @student = current_user
        @subjects = @student.subjects.includes(:exams, users: :subjects, school_class: :school_years)
        @school_years = SchoolYear.where(id: @subjects.map(&:school_class).map(&:school_year_ids).flatten.uniq)
        @exams = Exam.where(subject_id: @subjects.pluck(:id)).includes(:subject)

        @school_class = @subjects.map(&:school_class).compact.uniq || []
        
        # Fetch grades for each subject and quarter
        @grades = compute_grades
      end

      private

      def compute_grades
        grades = {}
      
        @subjects.each do |subject|
          # Initialize grades hash for each subject
          grades[subject.id] = { q1: 0, q2: 0, q3: 0, q4: 0 }
      
          subject.exams.each do |exam|
            # Find response for the exam by the student
            response = Response.find_by(exam_id: exam.id, user_id: @student.id)
            Rails.logger.debug "Exam: #{exam.name}, Response: #{response.inspect}"
      
            # Only calculate score if the response exists and has an answer
            next unless response&.answer.present?
      
            # Calculate percentage score for the response
            percentage_score = calculate_response_stats(response, exam)[:percentage]
            Rails.logger.debug "Percentage Score for Exam #{exam.id}: #{percentage_score}"
      
            # Add score to the correct quarter
            quarter = exam.quarter.name.to_i  # Assuming quarter is stored as an integer
            case quarter
            when 1 then grades[subject.id][:q1] += percentage_score
            when 2 then grades[subject.id][:q2] += percentage_score
            when 3 then grades[subject.id][:q3] += percentage_score
            when 4 then grades[subject.id][:q4] += percentage_score
            else
              Rails.logger.warn "Unexpected quarter value #{quarter} for exam #{exam.id}"
            end
          end
        end
      
        grades
      end
      
      def calculate_response_stats(response, exam)
        return default_stats unless response&.answer.present? && exam.answer_key.present?
      
        student_answers = response.answer.chars
        correct_answers = exam.answer_key.chars
        items_count = exam.items
      
        correct = 0
        student_answers.each_with_index do |student_answer, index|
          break if index >= items_count
      
          correct += 1 if student_answer == correct_answers[index]
        end
      
        # Calculate percentage based on the total items in the exam
        total_score = correct
        percentage = (total_score.to_f / items_count) * 100
      
        { total_score: total_score, percentage: percentage }
      end
      

      def default_stats
        { total_score: 0 }
      end
    end
  end
end
