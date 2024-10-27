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
            already_assigned_teachers = update_teachers
            set_flash_message(already_assigned_teachers)
          end

          def set_school_class_data
            @school_class = SchoolClass.find(params[:class_id])
            @school_year = @school_class.school_years.find(params[:school_year_id])
            @school_section = @school_class.school_sections.find(params[:school_section_id])
            @selected_subjects = Subject.where(id: params[:subject_ids])
          end

          def update_teachers
            already_assigned_teachers = [] # Initialize as an array
          
            selected_teachers.each do |teacher|
              school_class = SchoolClass.find(@school_class.id)
              sy = school_class.school_years.find(@school_year.id)
              section = sy.school_sections.find(@school_section.id)
          
              @selected_subjects.each do |subject|
                if section.users.exists?(teacher.id) && teacher.subjects.include?(subject)
                  already_assigned_teachers << teacher.name # Add to already assigned list
                else
                  section.users << teacher unless section.users.include?(teacher)
                  teacher.subjects << subject unless teacher.subjects.include?(subject)
                end
              end
            end
          
            already_assigned_teachers # Return array of already assigned teachers
          end
          

          def selected_teachers
            @selected_teachers ||= User.where(id: selected_teacher_ids, role: 'teacher')
          end

          def set_flash_message(already_assigned_teachers)
            newly_assigned_count = selected_teachers.size - already_assigned_teachers.size
          
            # Set flash message for newly assigned teachers
            if newly_assigned_count > 0
              flash[:toast] = "#{newly_assigned_count} teachers were successfully assigned."
            end
          
            # Set flash alert for teachers who were already assigned
            if already_assigned_teachers.any?
              flash[:toast] = "The teachers is already exists: #{already_assigned_teachers.join(', ')}"
            end
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
