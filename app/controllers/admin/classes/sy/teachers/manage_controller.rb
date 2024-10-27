# frozen_string_literal: true

module Admin
  module Classes
    module Sy
      module Teachers
        class ManageController < Admin::LayoutController
          include SearchableConcern
          include ErrorConcern

          before_action :set_class
          before_action :set_search, only: %i[index]

          def index
            set_default_sort(default_sort_column: 'name asc')
            @q = User.ransack(params[:q])
            @users = @q.result(distinct: true).where(role: 'teacher').page(params[:page]).per(10)
            @subjects = @class.subjects.distinct
            @sort_fields = {
              'Name': 'name asc',
              'Email': 'email asc',
              'Created At': 'created_at asc',
              'Updated At': 'updated_at asc'
            }
          end

          def create
            handle_missing_fields and return if missing_required_fields?

            if selected_teacher_ids.present?
              assign_teachers
            else
              flash[:toast] = 'No teachers were selected.'
            end
            redirect_to_index
          end

          def show
            @teacher = teacherAccount.find(params[:id])
          end

          def unassign_selected
            if params[:teacher_ids].present? && params[:school_section_id].present?
              school_section = SchoolSection.find_by(id: params[:school_section_id])
              
              if school_section
                teachers = User.where(id: params[:teacher_ids], role: 'teacher')
                teachers.each do |teacher|
                  teacher.school_sections.delete(school_section)
                  teacher.subjects.clear # Clear all subject associations for this section
                end
                
                flash[:toast] = "Successfully unassigned #{teachers.count} teachers"
              else
                flash[:toast] = "School section not found"
              end
            else
              flash[:toast] = "No teachers selected or section not specified"
            end
            
            redirect_to admin_classes_manage_path(params[:class_id])
          end

          private

          def missing_required_fields?
            @class.school_years.blank? || @class.school_sections.blank?
          end

          def handle_missing_fields
            flash[:toast] = 'School year and sections cannot be empty.'
            redirect_to_index
          end

          def assign_teachers
            set_school_class_data
            update_teachers
            set_flash_message
          end

          def set_school_class_data
            @school_class = SchoolClass.find(params[:class_id])
            @school_year = @school_class.school_years.find(params[:school_year_id])
            @school_section = @school_class.school_sections.find(params[:school_section_id])
            @selected_subjects = Subject.where(id: params[:subject_ids])
          end

          def update_teachers
            selected_teachers.each do |teacher|
              school_class = SchoolClass.find(@school_class.id)
              sy = school_class.school_years.find(@school_year.id)
              section = sy.school_sections.find(@school_section.id)
              section.users << teacher
              teacher.subjects << @selected_subjects
            end
          end

          def selected_teachers
            @selected_teachers ||= User.where(id: selected_teacher_ids, role: 'teacher')
          end

          def set_flash_message
            flash[:toast] = "#{selected_teachers.size} teachers were successfully assigned."
          end

          def selected_teacher_ids
            params[:teacher_ids]
          end

          def redirect_to_index
            redirect_to admin_classes_class_sy_teachers_manage_index_path(class_id: @class.id)
          end

          def set_class
            @class = SchoolClass.find(params[:class_id])
            # @teacher_accounts = @class.school_sections.flat_map(&:users).uniq
          end

          def set_search
            @q = User.ransack(params[:q])
            @users = @q.result(distinct: true).where(role: 'teacher').page(params[:page]).per(10)
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
