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
      
        # Get the logged-in student
        @student = current_user
      
        # Get all subjects for the logged-in student
        @subjects = @student.subjects.includes(:exams)
      
        # Get all exams for the student's subjects
        @exams = Exam.where(subject_id: @subjects.pluck(:id)).includes(:subject)
      
        # If you need @students for other purposes, initialize it here
        @students = User.where(role: 'student') # Or set to [] if not needed
      end
      
    end
  end
end