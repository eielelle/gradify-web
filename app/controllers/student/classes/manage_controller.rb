module Student
    module Classes
      class ManageController < Student::LayoutController
        before_action :authenticate_user!
        include SearchableConcern
        include ErrorConcern
        include PaperTrailConcern
  
        def index
          @student_classes = current_user.school_sections.includes(:school_class).map(&:school_class).uniq
  
          if @student_classes.empty?
            flash.now[:notice] = "You are not enrolled in any classes."
          end
        end
  
        private
  
        def authorize_student
          unless current_user.role == 'student'
            flash[:alert] = "You are not authorized to access this page."
            redirect_to root_path
          end
        end
      end
    end
  end
  