# frozen_string_literal: true

module Teacher
  module Classes
    class ManageController < Teacher::LayoutController
      before_action :authenticate_user!
      before_action :redirect_if_default_password
      include SearchableConcern
      include ErrorConcern

      def index
        return if performed?

        @school_classes = SchoolClass
                            .joins(school_sections: :users)
                            .where(users: { id: current_user.id, role: 'teacher' })
                            .distinct

        @show_pass_prompt = current_user.password_set_to_default
        set_default_sort(default_sort_column: 'name asc')
        @school_classes = query_items_default(@school_classes, params) if @school_classes.respond_to?(:to_sql)
        flash[:notice] = "No classes assigned to you yet." if @school_classes.empty?
      end

      def show
        set_class
        fetch_selected_students
        fetch_dropdown_data
        
        check_and_filter_students
        check_and_filter_teachers

        filter_students_by_subject if params[:subject_id].present?

        @student_count = @students.nil? ? 0 : @students.count
        @teacher_count = @teachers.nil? ? 0 : @teachers.count
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

        if school_year_id.present? && section_id.present?
          filter_teachers(school_year_id, section_id)
        elsif @school_year.any? && @sections.any?
          filter_teachers(@school_year.first.id, @sections.first.id)
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
      
        @students = @school_class.users.where(role: 'student')
      end

      def fetch_dropdown_data
        @school_year = SchoolYear.joins(school_sections: :users)
                                 .where(users: { id: current_user.id, role: 'teacher' })
                                 .distinct
      
        @sections = SchoolSection.joins(:users, :school_year)
                                 .where(users: { id: current_user.id, role: 'teacher' })
                                 .where(school_year: { id: @school_year.ids })
                                 .distinct
      
        @subjects = @school_class.subjects
      end
      
      def filter_students_by_subject
        selected_subject = Subject.find(params[:subject_id])
      
        @students = @students.joins(:subjects).where(subjects: { id: selected_subject.id })
      end

      def filter_students(school_year, section)
        section = SchoolSection.where(school_year_id: school_year, id: section)
                               .joins(:users)
                               .where(users: { role: 'student' })
                               .distinct
        @students = section.first.users.where(role: 'student') if section.present?
      end

      def filter_teachers(school_year, section)
        section = SchoolSection.where(school_year_id: school_year, id: section)
                               .joins(:users)
                               .where(users: { role: 'teacher' })
                               .distinct
        @teachers = section.first.users.where(role: 'teacher') if section.present?
      end

      def class_params
        params.permit(:name, :description)
      end

      def account_not_found
        flash[:notice] = 'Account not found.'
        render :edit, status: :unprocessable_entity
      end

      def set_class
        @school_class = SchoolClass.find(params[:id])
      end

      def redirect_if_default_password
        if current_user.password_set_to_default
          flash[:alert] = "Please change your default password for security purposes."
          redirect_to teacher_config_path and return
        end
      end
    end
  end
end
