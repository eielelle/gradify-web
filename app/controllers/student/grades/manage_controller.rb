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
      
        # Ensure @school_class is an array, even if no classes are found
        @school_class = @subjects.map(&:school_class).compact.uniq || []
        
        # Fetch grades for each subject and quarter
        @grades = compute_grades
      end

      private

      def compute_grades
        grades = {}
        @subjects.each do |subject|
          grades[subject.id] = { q1: 0, q2: 0, q3: 0, q4: 0 }
          subject.exams.each do |exam|
            response = Response.find_by(exam_id: exam.id, user_id: @student.id)
            next unless response && response.score

            # Example: Assign exam scores to quarters (you might adjust this based on exam dates or other criteria)
            case exam.quarter
            when 1 then grades[subject.id][:q1] += response.score
            when 2 then grades[subject.id][:q2] += response.score
            when 3 then grades[subject.id][:q3] += response.score
            when 4 then grades[subject.id][:q4] += response.score
            end
          end
        end
        grades
      end
    end
  end
end
