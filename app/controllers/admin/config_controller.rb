# frozen_string_literal: true

module Admin
  class ConfigController < Admin::LayoutController
    layout 'application'

    include ErrorConcern
    # include PaperTrailConcern
    include PasswordConcern

    def show
      @admin = current_user
    end

    def update
      admin = User.find(current_user.id)

      if admin.update(profile_update_params)
        flash[:toast] = 'Account updated successfully'
      else
        handle_errors(admin)
      end

      redirect_to admin_config_path
    end

    def destroy
      if current_user.valid_password? params[:password]
        current_user.destroy
        flash[:alert] = 'Account deleted successfully'
        redirect_to new_admin_account_session_path
      else
        flash[:password_error] = 'Invalid password'
        redirect_to admin_confirm_destroy_path
      end
    end

    def change_password
      update_model_password user: current_user
    end

    private

    def admin_update_password_params; end

    def profile_update_params
      params.require(:user).permit(:email, :name)
    end

    def edit_password_path
      admin_config_path
    end

    def after_update_path
      flash[:alert] = 'Password has been updated. Please sign in to continue.'
      new_admin_account_session_path
    end
  end
end
