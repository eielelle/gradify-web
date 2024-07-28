# frozen_string_literal: true

module Admin
  module Admins
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

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
        
        if @admin.permission.name == 'SuperAdmin'
          flash[:toast] = 'Cannot update SuperAdmin'
          redirect_to admin_admins_manage_index_path
          return
        end

        return unless @admin.destroy

        flash[:toast] = 'Account deleted successfully.'
        redirect_to admin_admins_manage_index_path
      end

      def edit
        set_admin
      end

      def update
        set_admin

        flash[:notice] = 'Account not found.' if @admin.nil?
        
        if @admin.permission.name == 'SuperAdmin'
          flash[:notice] = 'Cannot update SuperAdmin'
          render :edit, status: :unprocessable_entity
          return
        end

        if @admin.update(update_admin_params[:admin_account])
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_admins_manage_index_path
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
    end
  end
end
