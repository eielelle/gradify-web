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

          def unassign_selected
            if params[:student_ids].present? && params[:school_section_id].present?
              school_section = SchoolSection.find_by(id: params[:school_section_id])
              
              if school_section
                students = User.where(id: params[:student_ids], role: 'student')
                students.each do |student|
                  student.school_sections.delete(school_section)
                  student.subjects.clear # Clear all subject associations for this section
                end
                
                flash[:toast] = "Successfully unassigned #{students.count} students"
              else
                flash[:toast] = "School section not found"
              end
            else
              flash[:toast] = "No students selected or section not specified"
            end
            
            redirect_to admin_classes_manage_path(params[:class_id])
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
              
              existing_section = student.school_sections.find_by(school_year_id: @school_year.id)
          
              if existing_section
                
                already_assigned_students << "#{existing_section.name}"
              else

                @school_section.users << student
                @selected_subjects.each do |subject|
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
          
            
            if newly_assigned_count.positive?
              flash[:toast] = "#{newly_assigned_count} students were successfully assigned."
            end
          
            
            if already_assigned_students.any?
              flash[:toast] = "Already assigned in: #{already_assigned_students.join(', ')}"
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