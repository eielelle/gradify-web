class Admin::Admins::ConfigController < Admin::LayoutController
    include ErrorConcern
    include PaperTrailConcern
    include PasswordConcern

    def show
        @admin = current_admin_account
    end

    def update
        admin = AdminAccount.find(current_admin_account.id)

        if admin.update(profile_update_params)
            flash[:toast] = "Account updated successfully"
        else
            handle_errors(admin)
        end

        redirect_to admin_config_path
    end

    def destroy

    end

    def change_password
        update_model_password user: current_admin_account
    end

    private

    def admin_update_password_params
    end
    
    def profile_update_params
        params.require(:admin_account).permit(:email, :name)
    end

    def edit_password_path
      admin_config_path
    end
  
    def after_update_path
        flash[:alert] = "Password has been updated. Please sign in to continue."
        new_admin_account_session_path
    end


end
