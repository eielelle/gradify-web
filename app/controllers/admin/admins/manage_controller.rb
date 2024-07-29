# frozen_string_literal: true

module Admin
  module Admins
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern
      include SuperAdminConcern

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(AdminAccount, params)
      end

      def new
        @permissions = Permission.all
      end

      def create
        permission = Permission.find(admin_params[:permission_id])

        return if permission.nil?

        admin = AdminAccount.new admin_params

        if admin.save
          redirect_to admin_admins_manage_index_path
        else
          handle_errors(admin)
          redirect_to new_admin_admins_manage_path
        end
      end

      def show
        set_admin
      end

      def destroy
        set_admin

        return if superadmin_redirect(@admin, admin_admins_manage_index_path, 'Cannot destroy Superadmin')

        return unless @admin.destroy

        flash[:toast] = 'Account deleted successfully.'
        redirect_to admin_admins_manage_index_path
      end

      def edit
        set_admin
      end

      def update
        set_admin

        account_not_found and return if @admin.nil?

        return if superadmin_redirect(@admin, edit_admin_admins_manage_path, 'Cannot edit Superadmin')

        if @admin.update(update_admin_params[:admin_account])
          update_success
          return
        else
          handle_errors(@admin)
        end

        render :edit, status: :unprocessable_entity
      end

      private

      def set_admin
        @admin = AdminAccount.includes(:permission).find(params[:id])
        @permissions = Permission.all
      end

      def admin_params
        params.permit(:name, :email, :permission_id, :password)
      end

      def update_admin_params
        params.permit(:id, admin_account: %i[name email permission_id])
      end

      def account_not_found
        flash[:notice] = 'Account not found.'
        render :edit, status: :unprocessable_entity
      end

      def update_success
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_admins_manage_index_path
      end
    end
  end
end
