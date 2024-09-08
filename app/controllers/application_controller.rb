# frozen_string_literal: true

class ApplicationController < ActionController::Base
    def after_sign_in_path_for(resource)
        case resource.role
        when 'superadmin'
            admin_root_path   # Customize the path for superadmin
        when 'admin'
            admin_dashboard_path        # Customize the path for admin
        when 'teacher'
            teacher_dashboard_path      # Customize the path for teacher
        when 'student'
            student_dashboard_path      # Customize the path for student
        else
            root_path                   # Default fallback path
        end
    end
end
