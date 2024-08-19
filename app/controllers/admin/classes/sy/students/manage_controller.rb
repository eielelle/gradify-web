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
            @students = @q.result(distinct: true).page(params[:page])
            @count = @students.total_count
          end

          def create
            selected_student_ids = params[:student_ids]

            if selected_student_ids.present?
              @students = StudentAccount.where(id: selected_student_ids)
            else
              flash[:alert] = 'No students were selected.'
              redirect_to admin_classes_manage_index_path and return
            end
            @school_class = SchoolClass.find(params[:id])
            render :show
          end

          def show
            @student = @class.student_accounts.find(params[:id])
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
