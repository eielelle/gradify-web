# frozen_string_literal: true

module Admin
  module Admins
    class PasswordController < Admin::LayoutController
      include PaperTrailConcern
      include ErrorConcern

      def edit
        redirect_to admin_admins_manage_index_path if AdminAccount.find_by(id: params[:id]).nil?
      end

      def update
        admin = AdminAccount.find(params[:id])

        if valid_password?(admin_password_params[:current_password])
          update_password(admin) ? successful_update : failed_update(admin)
        else
          flash[:current_password_error] = 'Password is incorrect'
          redirect_to edit_admin_admins_password_path
        end
      end

      private

      def admin_password_params
        params.permit(:current_password, :password, :password_confirmation)
      end

      def valid_password?(current_password)
        current_admin_account.valid_password?(current_password)
      end

      def update_password(admin)
        admin.update(admin_password_params.except(:current_password))
      end

      def successful_update
        flash[:toast] = 'Password updated successfully'
        redirect_to admin_admins_manage_index_path
      end

      def failed_update(admin)
        handle_errors(admin)
        redirect_to edit_admin_admins_password_path
      end
    end
  end
end
