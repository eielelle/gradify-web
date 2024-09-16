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

        if params[:school_year_id].present? && params[:school_section_id].present?
          filter_students(params[:school_year_id], params[:school_section_id])
        elsif !@sy.empty? && !@sections.empty?
          filter_students(@sy.first.id, @sections.first.id)
        end
        @count = @show.nil? ? 0 : @show.count
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

      def fetch_selected_students
        @selected_students = if params[:selected_student_ids].present?
                               SchoolClass.school_years.users
                             else
                               []
                             end
      end

      def fetch_dropdown_data
        @sy = @school_class.school_years.all
        @sections = @school_class.school_sections.all
      end

      def filter_students(sy, section)
        sections = SchoolSection.where(school_year_id: sy)
        section = sections.find(section)
        @show = section.users
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
