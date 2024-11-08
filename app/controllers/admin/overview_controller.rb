# frozen_string_literal: true

module Admin
  class OverviewController < Admin::LayoutController
    def index
      @total_students = User.where(role: 'student').count
      @total_teachers = User.where(role: 'teacher').count
      @total_admins = User.where(role: ['admin', 'superadmin']).count
      @total_classes = SchoolClass.where(params[:id]).count

      # Define an array to hold the count of students per month
      @studs = (1..12).map do |month|
        # Get the count of students for the given month and year (e.g., for 2024)
        User.where(role: 'student')
            .where(created_at: Date.new(Time.current.year, month, 1).beginning_of_month..Date.new(2024, month, 1).end_of_month)
            .count
      end
    end
  end
end
