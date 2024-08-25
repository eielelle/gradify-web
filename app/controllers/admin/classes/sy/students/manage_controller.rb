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
            selected_student_ids = params[:student_ids]

            if selected_student_ids.present?
              @school_class = SchoolClass.find(params[:class_id])
              @school_class.student_accounts << StudentAccount.where(id: selected_student_ids)
              redirect_to admin_classes_class_sy_students_manage_index_path(class_id: @school_class.id)
            else
              flash[:alert] = 'No students were selected.'

            end
          end

          def show
            @student = StudentAccount.find(params[:id])
          end

          private

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
