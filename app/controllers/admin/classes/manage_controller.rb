# frozen_string_literal: true

module Admin
  module Classes
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(SchoolClass, params)
      end

      def create
        school_class = SchoolClass.new class_params

        if school_class.save
          redirect_to admin_classes_manage_index_path
        else
          handle_errors(school_class)
          redirect_to new_admin_classes_manage_path
        end
      end

      def edit
        set_class

        redirect_to admin_classes_manage_index_path if @school_class.nil?
      end

      def show
        set_class
        fetch_selected_students
        fetch_dropdown_data

        check_and_filter_students
        check_and_filter_teachers

        @student_count = @students.nil? ? 0 : @students.count
        @teacher_count = @teachers.nil? ? 0 : @teachers.count
      end

      def update
        set_class

        account_not_found and return if @school_class.nil?

        if @school_class.update(update_class_params[:school_class])
          update_success
          return
        else
          handle_errors(@school_class)
        end

        render :edit, status: :unprocessable_entity
      end

      def destroy
        set_class

        return unless @school_class.destroy

        flash[:toast] = 'Class deleted successfully.'
        redirect_to admin_classes_manage_index_path
      end

      private

      def check_and_filter_students
        school_year_id = params[:student_school_year_id]
        section_id = params[:student_school_section_id]
        subject_id = params[:subject_id]

        if school_year_id.present? && section_id.present? 
          filter_students(school_year_id, section_id)
        elsif @school_year.any? && @sections.any? 
          filter_students(@school_year.first.id, @sections.first.id)
        end
      end

      def check_and_filter_teachers
        school_year_id = params[:teacher_school_year_id]
        section_id = params[:teacher_school_section_id]
        

        if school_year_id.present? && section_id.present? 
          filter_teachers(school_year_id, section_id)
        elsif @school_year.any? && @sections.any?
          filter_teachers(@school_year.first.id, @sections.first.id)
        end
      end

      def fetch_selected_students
        @selected_students = if params[:selected_student_ids].present?
                               SchoolClass.school_years.users
                             else
                               []
                             end
      end

      def fetch_dropdown_data
        @school_year = @school_class.school_years.all
        @sections = @school_class.school_sections.all
        @subjects = Subject.all
      end

      def filter_students(school_year, section)
        sections = SchoolSection.where(school_year_id: school_year)
        section = sections.find(section)
        @students = section.users.where(role: 'student')
      end

      def filter_teachers(school_year, section)
        sections = SchoolSection.where(school_year_id: school_year)
        section = sections.find(section)
        @teachers = section.users.where(role: 'teacher')
      end

      def update_class_params
        params.permit(:id, school_class: %i[name description])
      end

      def class_params
        params.permit(:name, :description)
      end

      def update_success
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_classes_manage_index_path
      end

      def account_not_found
        flash[:notice] = 'Account not found.'
        render :edit, status: :unprocessable_entity
      end

      def set_class
        @school_class = SchoolClass.find(params[:id])
      end
    end
  end
end
