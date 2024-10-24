# frozen_string_literal: true

module Admin
  module Classes
    module Sy
      module Students
        class ManageController < Admin::LayoutController
          include SearchableConcern
          include ErrorConcern

          before_action :set_class
          before_action :set_search, only: %i[index]

          def index
            set_default_sort(default_sort_column: 'name asc')
            query_items_default(StudentAccount, params)
          end

          def create
            handle_missing_fields and return if missing_required_fields?

            if selected_student_ids.present?
              assign_students
            else
              flash[:toast] = 'No students were selected.'
            end
            redirect_to_index
          end

          def show
            @student = StudentAccount.find(params[:id])
          end

          private

          def missing_required_fields?
            @class.school_years.blank? || @class.school_sections.blank?
          end

          def handle_missing_fields
            flash[:toast] = 'School year and sections cannot be empty.'
            redirect_to_index
          end

          def assign_students
            set_school_class_data
            update_students
            set_flash_message
          end

          def set_school_class_data
            @school_class = SchoolClass.find(params[:class_id])
            @school_year = @school_class.school_years.find(params[:school_year_id])
            @school_section = @school_class.school_sections.find(params[:school_section_id])
          end

          def update_students
            selected_students.each do |student|
              student.update(
                school_year_id: @school_year.id,
                school_section_id: @school_section.id,
                school_class_id: @school_class.id
              )
            end
          end

          def selected_students
            @selected_students ||= StudentAccount.where(id: selected_student_ids)
          end

          def set_flash_message
            flash[:toast] = "#{selected_students.size} students were successfully assigned."
          end

          def selected_student_ids
            params[:student_ids]
          end

          def redirect_to_index
            redirect_to admin_classes_class_sy_students_manage_index_path(class_id: @class.id)
          end

          def set_class
            @class = SchoolClass.find(params[:class_id])
            @student_accounts = @class.student_accounts
          end

          def set_search
            @q = @student_accounts.ransack(params[:q])
            @sort_fields = {
              'Name': 'name asc',
              'Email': 'email asc',
              'Created At': 'created_at asc',
              'Updated At': 'updated_at asc'
            }
          end
        end
      end
    end
  end
end
