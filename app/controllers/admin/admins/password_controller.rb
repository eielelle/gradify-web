# frozen_string_literal: true

module Admin
  module Admins
    class PasswordController < Admin::LayoutController
      include PaperTrailConcern
      include ErrorConcern
      include PasswordConcern
      include SuperAdminConcern

      def edit
        redirect_to admin_admins_manage_index_path if AdminAccount.find_by(id: params[:id]).nil?
      end

      def update
        return if superadmin_redirect(AdminAccount.find(params[:id]), edit_admin_admins_password_path, 'Cannot change password of SuperAdmin')

        update_model_password resource_class: AdminAccount
      end

      private

      def edit_password_path
        edit_admin_admins_password_path
      end

      def after_update_path
        admin_admins_manage_index_path
      end
    end
  end
end
