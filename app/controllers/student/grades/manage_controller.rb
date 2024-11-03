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
      
        # Set @school_class to the classes associated with the student's subjects
        @school_class = @subjects.map(&:school_class).compact.uniq
      end
      
      
    end
  end
end