# frozen_string_literal: true

module Admin
    module Workforce
      class ManageController < Admin::LayoutController
        include SearchableConcern
        include ErrorConcern
        include PasswordConcern
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
            redirect_to admin_workforce_manage_index_path
          else
            handle_errors(@user)
            redirect_to admin_workforce_manage_index_path
          end
        end
  
        def edit
          set_user
  
          redirect_to admin_workforce_manage_index_path if @user.nil? || @user.role == 'superadmin'
        end
  
        def update
          set_user
        
          return account_not_found if @user.nil?
          return if superadmin_redirect(@user, edit_admin_workforce_manage_path, 'Cannot edit Superadmin')
        
          if password_fields_filled_out?
            update_with_password
          elsif password_partially_filled_out?
            flash[:password_error] = 'New password required'
            render :edit, status: :unprocessable_entity
          elsif current_password_filled_without_new_password?
            flash[:password_error] = 'New password required to change password'
            flash[:password_confirmation_error] = 'Password Confirmation required to change password'
            render :edit, status: :unprocessable_entity
          else
            update_without_password
          end
        end
  
        private
  
        def set_user
          @user = User.find(params[:id])
          @roles = User.roles
        end
  
        def user_params
          params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
        end
  
        def update_user_params
          params.require(:user).permit(:name, :email, :role, :password, :password_confirmation, :current_password)
        end
  
        def account_not_found
          flash[:notice] = 'Account not found.'
          render :edit, status: :unprocessable_entity
        end
  
        def update_success
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_workforce_manage_index_path
        end

        def password_fields_filled_out?
          update_user_params[:password].present? && update_user_params[:password_confirmation].present?
        end
        
        def password_partially_filled_out?
          update_user_params[:password].present? || update_user_params[:password_confirmation].present?
        end
        
        def current_password_filled_without_new_password?
          update_user_params[:current_password].present? && !password_fields_filled_out?
        end
  
        def update_with_password
          if @user.update_with_password(update_user_params)
            bypass_sign_in(@user) if @user == current_user
            flash[:toast] = 'Updated Successfully.'
            redirect_to admin_workforce_manage_index_path
          else
            handle_errors(@user)
            render :edit, status: :unprocessable_entity
          end
        end
  
        def update_without_password
          if @user.update(update_user_params.except(:password, :password_confirmation, :current_password))
            flash[:toast] = 'Updated Successfully.'
            redirect_to admin_workforce_manage_index_path
          else
            handle_errors(@user)
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end
  end
  