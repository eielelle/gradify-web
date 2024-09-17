# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    role_paths[resource.role] || root_path
  end

  private

  def role_paths
    {
      'superadmin' => admin_root_path,
      'admin' => admin_dashboard_path,
      'teacher' => teacher_dashboard_path,
      'student' => student_dashboard_path
    }
  end
end
