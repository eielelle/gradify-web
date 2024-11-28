# frozen_string_literal: true

module Admin
  class OverviewController < Admin::LayoutController
    before_action :redirect_if_default_password
    
    def index
      return if performed?

      @total_students = User.where(role: 'student').count
      @total_teachers = User.where(role: 'teacher').count
      @total_admins = User.where(role: ['admin', 'superadmin']).count
      @total_classes = SchoolClass.where(params[:id]).count
      @show_pass_prompt = current_user.password_set_to_default

      # Define an array to hold the count of students per month
      @studs = (1..12).map do |month|
        # Get the count of students for the given month and year (e.g., for 2024)
        User.where(role: 'student')
            .where(created_at: Date.new(Time.current.year, month, 1).beginning_of_month..Date.new(2024, month, 1).end_of_month)
            .count
      end
    end

    private

    def redirect_if_default_password
      if current_user.password_set_to_default
        flash[:alert] = "Please change your default password for security purposes."
        redirect_to admin_config_path and return
      end
    end
  end
end