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
      
        @subjects = @student.subjects.includes(:exams)
      
        @exams = Exam.where(subject_id: @subjects.pluck(:id)).includes(:subject)
      
        @students = User.where(role: 'student') 
      end
      
    end
  end
end