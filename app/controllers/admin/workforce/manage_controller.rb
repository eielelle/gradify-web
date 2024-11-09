# frozen_string_literal: true

module Admin
  module Workforce
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern
      include SuperAdminConcern

      # before_action :authorize_admin

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_wf(User, params)
      end

      def new
        @user = User.new
        @roles = User.roles.reject { |key, _| ['student'].include?(key) }

        if current_user.role == 'admin'
          @roles = @roles.reject { |key, _| ['superadmin'].include?(key) }
        end
      end

      def create
        return if User.roles.keys.exclude?(user_params[:role])

        user = User.new(user_params)

        if user.save
          redirect_to admin_workforce_manage_index_path, notice: 'User was successfully created.'
        else
          handle_errors(user)
          redirect_to new_admin_workforce_manage_path
        end
      end

      def show
        set_user
      end

      def destroy
        set_user

        return if superadmin_redirect(@user, admin_workforce_manage_index_path, 'Cannot destroy Superadmin')

        if @user.destroy
          flash[:toast] = 'Account deleted successfully.'
        else
          handle_errors(@user)
        end
        redirect_to admin_workforce_manage_index_path
      end

      def edit
        set_user

        redirect_to admin_workforce_manage_index_path if @user.nil? || @user.role == 'superadmin'
      end

      def update
        set_user

        return account_not_found if @user.nil?
        return if superadmin_redirect(@user, edit_admin_workforce_manage_path, 'Cannot edit Superadmin')

        if @user.update(update_user_params)
          update_success
        else
          handle_errors(@user)
          redirect_to edit_admin_workforce_manage_path(@user, hide: true)
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
        @roles = User.roles
      end

      def user_params
        params.require(:user).permit(:name, :email, :role, :password)
      end

      def update_user_params
        params.require(:user).permit(:name, :email)
      end

      def account_not_found
        flash[:notice] = 'Account not found.'
        render :edit, status: :unprocessable_entity
      end

      def update_success
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_workforce_manage_index_path
      end
    end
  end
end
