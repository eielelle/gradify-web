# frozen_string_literal: true

module Admin
    module Workforce
      class PasswordController < Admin::LayoutController
        include ErrorConcern
        include PasswordConcern
        include SuperAdminConcern
  
        def edit
          @user = User.find_by(id: params[:id])
          redirect_to admin_workforce_manage_index_path if @user.nil? || @user.role == 'superadmin'
        end
  
        def update
          return if superadmin_redirect(User.find(params[:id]), edit_admin_workforce_password_path,
                                        'Cannot change password of SuperAdmin')
  
          update_model_password resource_class: User
        end
  
        private
  
        def edit_password_path
          edit_admin_workforce_password_path
        end
  
        def after_update_path
          admin_workforce_manage_index_path
        end
      end
    end
  end
  