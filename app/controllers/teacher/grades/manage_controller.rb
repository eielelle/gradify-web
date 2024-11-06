# frozen_string_literal: true

module Teacher
  module Grades
    class ManageController < Teacher::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern
      include GradeBookHelper

      def index
        set_default_sort(default_sort_column: 'name asc')
        @teacher = current_user
        @subjects = @teacher.subjects.includes(:exams)
        
        # Get all available classes, school years, sections and subjects for filtering
        @school_classes = SchoolClass.joins(school_years: { school_sections: :users })
                                    .where(school_years: { school_sections: { id: @teacher.school_section_ids } })
                                    .distinct
        
        @school_years = if params[:school_class_id].present?
          SchoolYear.joins(school_sections: :users)
                    .where(school_class_id: params[:school_class_id])
                    .where(school_sections: { id: @teacher.school_section_ids })
                    .distinct
        else
          SchoolYear.joins(school_sections: :users)
                    .where(school_sections: { id: @teacher.school_section_ids })
                    .distinct
        end
        
        @sections = if params[:school_year_id].present?
          SchoolSection.where(id: @teacher.school_section_ids)
                       .where(school_year_id: params[:school_year_id])
        else
          SchoolSection.where(id: @teacher.school_section_ids)
        end
        
        # Build search query
        @q = User.ransack(params[:q])
        @q.sorts = params[:q][:s] if params[:q]&.key?(:s)
        
        # Start with base query
        @students = @q.result(distinct: true)
                    .joins(:school_sections, :subjects)
                    .joins('INNER JOIN school_years ON school_sections.school_year_id = school_years.id')
                    .joins('INNER JOIN school_classes ON school_years.school_class_id = school_classes.id')
                    .where(role: 'student')
                    .where(school_sections: { id: @teacher.school_section_ids })
                    .where(subjects: { id: @subjects.pluck(:id) })
        
        # Apply filters if present
        @students = @students.where(school_classes: { id: params[:school_class_id] }) if params[:school_class_id].present?
        @students = @students.where(school_years: { id: params[:school_year_id] }) if params[:school_year_id].present?
        @students = @students.where(school_sections: { id: params[:section_id] }) if params[:section_id].present?
        @students = @students.where(subjects: { id: params[:subject_id] }) if params[:subject_id].present?
        
        # Include necessary associations
        @students = @students.includes(:school_sections, :subjects, school_sections: { school_year: :school_class })
        
        @exams = if params[:subject_id].present?
          Exam.where(subject_id: params[:subject_id])
        else
          Exam.where(subject_id: @subjects.pluck(:id))
        end
        
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