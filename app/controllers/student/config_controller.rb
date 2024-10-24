# frozen_string_literal: true

module Student
    class ConfigController < Student::LayoutController
      layout 'application'
  
      include ErrorConcern
      include PaperTrailConcern
      include PasswordConcern
  
      def show
        @student = current_user
      end
  
      def update
        student = User.find(current_user.id)
  
        if student.update(profile_update_params)
          flash[:toast] = 'Account updated successfully'
        else
          handle_errors(student)
        end
  
        redirect_to student_config_path
      end
  
      def destroy
        if current_user.valid_password? params[:password]
          current_user.destroy
          flash[:alert] = 'Account deleted successfully'
          redirect_to new_user_session_path
        else
          flash[:password_error] = 'Invalid password'
          redirect_to student_confirm_destroy_path
        end
      end
  
      def change_password
        update_model_password user: current_user
      end
  
      private
  
      def profile_update_params
        params.require(:user).permit(:email, :name)
      end
  
      def edit_password_path
        student_config_path
      end
  
      def after_update_path
        flash[:alert] = 'Password has been updated. Please sign in to continue.'
        new_user_session_path
      end
    end
end