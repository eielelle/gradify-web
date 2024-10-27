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
            @q = User.ransack(params[:q])
            @users = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10)
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
            @class.school_years.blank? || @class.school_sections.blank? || params[:subject_ids].blank?
          end

          def handle_missing_fields
            flash[:toast] = 'School year, sections, and subjects cannot be empty.'
            redirect_to_index
          end

          def assign_students
            set_school_class_data
            already_assigned_students = update_students
            set_flash_message(already_assigned_students)
          end

          def set_school_class_data
            @school_class = SchoolClass.find(params[:class_id])
            @school_year = @school_class.school_years.find(params[:school_year_id])
            @school_section = @school_class.school_sections.find(params[:school_section_id])
            @selected_subjects = Subject.where(id: params[:subject_ids])
          end

          def update_students
            already_assigned_students = []
              selected_students.each do |student|
                            school_class = SchoolClass.find(@school_class.id)
                            sy = school_class.school_years.find(@school_year.id)
                            section = sy.school_sections.find(@school_section.id)
                        
                            @selected_subjects.each do |subject|
                              if section.users.exists?(student.id) && student.subjects.include?(subject)
                                already_assigned_students << student.name # Add to already assigned list
                              else
                                section.users << student unless section.users.include?(student)
                                student.subjects << subject unless student.subjects.include?(subject)
                              end
                            end
                          end
            already_assigned_students
          end

          def selected_students
            @selected_students ||= User.where(id: selected_student_ids, role: 'student')
          end

          def set_flash_message(already_assigned_students)
            newly_assigned_count = selected_students.size - already_assigned_students.size
          
            # Set flash message for newly assigned teachers
            if newly_assigned_count > 0
              flash[:toast] = "#{newly_assigned_count} students were successfully assigned."
            end
          
            # Set flash alert for teachers who were already assigned
            if already_assigned_students.any?
              flash[:toast] = "The students is already exists: #{already_assigned_students.join(', ')}"
            end
          end

          def selected_student_ids
            params[:student_ids]
          end

          def redirect_to_index
            redirect_to admin_classes_class_sy_students_manage_index_path(class_id: @class.id)
          end

          def set_class
            @class = SchoolClass.find(params[:class_id])
          end

          def set_search
            @q = User.ransack(params[:q])
            @users = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10)
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