# frozen_string_literal: true

module Teacher
    class LayoutController < ApplicationController
      #   include HandleAccessDeniedConcern
  
      layout 'teacher_panel'
      before_action :auth_user
      #   # load_and_authorize_resource
  
      #   # in ApplicationController
      #   def current_ability
      #     @current_ability ||= if current_admin_account.present?
      #                            Ability.new(current_admin_account)
      #                          else
      #                            Ability.new(current_user)
      #                          end
      #   end
  
      private
  
      def auth_user
        authenticate_user!
        unless current_user&.role == 'teacher'
            sign_out current_user
            redirect_to user_session_path, alert: 'You are not authorized to access this page.'
          end
      end
    end
  end
  