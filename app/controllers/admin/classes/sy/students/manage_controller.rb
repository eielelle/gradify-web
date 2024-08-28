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
              redirect_to_index
            else
              flash[:toast] = 'No students were selected.'
            end
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
            @school_class = SchoolClass.find(params[:class_id])
            @school_class.student_accounts << StudentAccount.where(id: selected_student_ids)
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
