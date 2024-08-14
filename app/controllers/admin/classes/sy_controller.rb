# frozen_string_literal: true

module Admin
  module Classes
    class SyController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern

      def index
        set_class
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(@class.school_years, params)
        end

      def new

      end

      def create
        set_class
        sy = @class.school_years.new school_year_params

        return if is_date_present
        return if is_date_valid

        if sy.save
          redirect_to admin_classes_class_sy_index_path
        else
          handle_errors(sy)
          redirect_to new_admin_classes_class_sy_path
        end
      end

      def show
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(SchoolYear, params)
      end

      private

      def set_class
        @class = SchoolClass.find(params[:class_id])
      end

      def is_date_valid
        start_date = school_year_params[:start].to_date
        end_date = school_year_params[:end].to_date

        if end_date < start_date
            flash[:end_error] = "End date should be later than start date"
            redirect_to new_admin_classes_class_sy_path
            return true
        end

        return false
      end

      def is_date_present
        start_date = school_year_params[:start].to_date
        end_date = school_year_params[:end].to_date

        if start_date.nil? || end_date.nil?
            flash[:start_error] = "Start date is required" if start_date.nil?
            flash[:end_error] = "End date is required" if end_date.nil?
            redirect_to new_admin_classes_class_sy_path
            
            return true
        end

        return false
      end

      def school_year_params
        # First, permit the required parameters
        permitted_params = params.permit(:name, :start, :end)

        # Convert the start and end parameters to Date objects if they are present
        permitted_params[:start] = permitted_params[:start].to_date if permitted_params[:start].present?
        permitted_params[:end] = permitted_params[:end].to_date if permitted_params[:end].present?

        # Return the modified parameters
        permitted_params
      end
    end
  end
end
