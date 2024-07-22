class Admin::Admins::PasswordController < Admin::LayoutController
    include PaperTrailConcern
    include ErrorConcern

    def edit
        redirect_to admin_admins_manage_index_path if AdminAccount.find_by(id: params[:id]).nil?
    end

    def update
        admin = AdminAccount.find(params[:id])
        
        if current_admin_account.valid_password?(admin_password_params[:current_password])
            if admin.update(admin_password_params.except(:current_password))
                flash[:toast] = "Password updated successfully"
                redirect_to admin_admins_manage_index_path
            else
                handle_errors(admin)
            end
        else
            flash[:current_password_error] = "Password is incorrect"
            redirect_to edit_admin_admins_password_path
        end
    end

    private

    def admin_password_params
        params.permit(:current_password, :password, :password_confirmation)
    end
end
