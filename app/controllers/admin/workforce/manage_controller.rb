# frozen_string_literal: true

module Admin
    module Workforce
      class ManageController < Admin::LayoutController
        include SearchableConcern
        include ErrorConcern
        # include PaperTrailConcern
        include SuperAdminConcern

        # before_action :authorize_admin
  
        def index
          set_default_sort(default_sort_column: 'name asc')
          query_items_default(User, params)
        end
  
        def new
          @roles = User.roles
        end
  
        def create
          return if User.roles.keys.exclude?(user_params['role'])
  
          user = User.new user_params
  
          if user.save
            redirect_to admin_workforce_manage_index_path
          else
            handle_errors(user)
            redirect_to new_admin_workforce_manage_path
          end
        end
  
        def show
          @user = User.find(params[:id])
        end
  
        def destroy
          set_admin
  
          return if superadmin_redirect(@admin, admin_admins_manage_index_path, 'Cannot destroy Superadmin')
  
          return unless @admin.destroy
  
          flash[:toast] = 'Account deleted successfully.'
          redirect_to admin_admins_manage_index_path
        end
  
        def edit
          set_user
  
          redirect_to admin_workforce_manage_index_path if @user.nil? || @user.role == 'superadmin'
        end
  
        def update
          set_user
  
          account_not_found and return if @user.nil?
  
          return if superadmin_redirect(@user, edit_admin_workforce_manage_path, 'Cannot edit Superadmin')
  
          if @user.update(update_user_params[:user])
            update_success
            return
          else
            handle_errors(@user)
          end
  
          render :edit, status: :unprocessable_entity
        end
  
        private
  
        def authorize_admin
          authorize! :manage, :admin
        end
  
        def set_user
          @user = User.find(params[:id])
          @roles = User.roles
        end
  
        def user_params
          params.permit(:name, :email, :role, :password)
        end
  
        def update_user_params
          params.permit(:id, user: %i[name email role])
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
  