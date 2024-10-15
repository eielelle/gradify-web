# frozen_string_literal: true

module Student
    class LayoutController < ApplicationController
      include UserRoleAuthConcern
  
      layout 'student_panel'
      before_action :auth_user
  
      private
  
      def auth_user
        auth_user_role(['student'])
      end
    end
  end