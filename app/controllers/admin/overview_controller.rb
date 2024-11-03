# frozen_string_literal: true

module Admin
  class OverviewController < Admin::LayoutController
    def index
      @total_students = User.where(role: 'student').count
      @total_teachers = User.where(role: 'teacher').count
      @total_admins = User.where(role: ['admin', 'superadmin']).count
      @total_classes = SchoolClass.where(params[:id]).count
    end
  end
end
