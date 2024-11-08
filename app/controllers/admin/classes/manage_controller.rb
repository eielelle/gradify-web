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
      
        # Apply the school section filter first to get initial set of students and teachers
        check_and_filter_students
        check_and_filter_teachers
      
        # Narrow down the filtered students and teachers by the selected subject
        filter_students_by_subject if params[:subject_id].present?
      
        # Set counts for students and teachers
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
      
        if @school_class.users.exists?
          flash[:toast] = "Cannot delete this class because there are assigned students or teachers."
          redirect_to admin_classes_manage_index_path
        else
          if @school_class.destroy
            flash[:toast] = 'Class deleted successfully.'
            redirect_to admin_classes_manage_index_path
          else
            flash[:toast] = "An error occurred while deleting the class."
            redirect_to admin_classes_manage_index_path
          end
        end
      end

      private
      
      def filter_students_by_subject
        selected_subject = Subject.find(params[:subject_id])
      
        # Refine @teachers and @students based on the selected subject
        @teachers = @teachers.where(id: selected_subject.users.where(role: 'teacher').pluck(:id))
        @students = @students.where(id: selected_subject.users.where(role: 'student').pluck(:id))
      end

      def check_and_filter_students
        school_year_id = params[:student_school_year_id]
        section_id = params[:student_school_section_id]
        

        if school_year_id.present? && section_id.present?
          filter_students(school_year_id, section_id)
        elsif @school_year.any? && @sections.any?
          filter_students(@school_year.first.id, @sections.first.id)
        end
      end

      def check_and_filter_teachers
        school_year_id = params[:teacher_school_year_id]
        section_id = params[:teacher_school_section_id]
        subject_id = params[:subject_id]

        if school_year_id.present? && section_id.present?
          filter_teachers(school_year_id, section_id, subject_id)
        elsif @school_year.any? && @sections.any?
          filter_teachers(@school_year.first.id, @sections.first.id, subject_id)
        end
      end

      def fetch_selected_students
        existing_student_ids = @school_class.users.where(role: 'student').pluck(:id)
        if params[:selected_student_ids].present?
          new_student_ids = params[:selected_student_ids] - existing_student_ids
          @selected_students = User.where(id: new_student_ids)
        else
          @selected_students = []
        end
      end

      def fetch_dropdown_data
        @school_year = @school_class.school_years.all
        @sections = @school_class.school_sections.all
        @subjects = @school_class.subjects
      end

      def filter_students(school_year, section)
        sections = SchoolSection.where(school_year_id: school_year)
        section = sections.find_by(id: section) # Change to find_by
        if section
          @students = section.users.where(role: 'student')
        else
          @students = User.none # Set to an empty relation if section is not found
          flash[:alert] = "Section not found for the given school year."
        end
      end

      def filter_teachers(school_year, section, subject_id = nil)
        sections = SchoolSection.where(school_year_id: school_year)
        section = sections.find_by(id: section) # Change to find_by
        if section
          @teachers = section.users.where(role: 'teacher')

          # Further filter teachers by subject if subject_id is provided
          @teachers = @teachers.joins(:subjects).where(subjects: { id: subject_id }) if subject_id.present?
        else
          @teachers = User.none # Set to an empty relation if section is not found
          flash[:alert] = "Section not found for the given school year."
        end
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
