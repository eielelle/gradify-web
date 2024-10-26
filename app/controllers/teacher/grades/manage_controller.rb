# frozen_string_literal: true

module Teacher
  module Grades
    class ManageController < Teacher::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      def index
        set_default_sort(default_sort_column: 'name asc')
        @teacher = current_user
        @subjects = @teacher.subjects.includes(:exams)
        
        # Build search query
        @q = User.ransack(params[:q])
        @q.sorts = params[:q][:s] if params[:q]&.key?(:s)
        
        # Get filtered students
        @students = @q.result(distinct: true)
                .joins(:school_sections, :subjects)
                .joins('INNER JOIN school_years ON school_sections.school_year_id = school_years.id')
                .joins('INNER JOIN school_classes ON school_years.school_class_id = school_classes.id')
                .where(role: 'student')
                .where(school_sections: { id: @teacher.school_section_ids })
                .where(subjects: { id: @subjects.pluck(:id) })
                .includes(:school_sections, :subjects, school_sections: { school_year: :school_class })
        
        @exams = Exam.where(subject_id: @subjects.pluck(:id))
        
        # Set up sorting options
        @sort_fields = [
          ['Name (A-Z)', 'name asc'],
          ['Name (Z-A)', 'name desc'],
          ['Section (A-Z)', 'school_sections_name asc'],
          ['Section (Z-A)', 'school_sections_name desc']
        ]
        
        # Pagination
        @items = @students.page(params[:page]).per(10)
        @count = @students.count
      end
    end
  end
end
