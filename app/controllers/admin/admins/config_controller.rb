class Admin::Admins::ConfigController < ApplicationController
    include ErrorConcern
    include PaperTrailConcern

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

    end

    private

    def admin_update_password_params
    end
    
    def profile_update_params
        params.require(:admin_account).permit(:email, :name)
    end


end
