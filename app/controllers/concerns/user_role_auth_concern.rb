# frozen_string_literal: true

module UserRoleAuthConcern
  extend ActiveSupport::Concern

  included do
    def auth_user_role(roles)
      authenticate_user! # First ensure the user is logged in
      return unless roles.exclude?(current_user&.role)

      sign_out current_user
      redirect_to user_session_path, alert: 'You are not authorized to access this page.'
    end
  end
end
