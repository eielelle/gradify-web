# frozen_string_literal: true

module Admin
  module Classes
    module Sy
      class ManageController < Admin::LayoutController
        include SearchableConcern
        include ErrorConcern

        def index
          set_class
          set_default_sort(default_sort_column: 'name asc')
          query_items_default(@class.school_years, params)
        end

        def new; end

        def destroy
          set_class

          return unless @class.school_years.find(params[:id]).destroy

          flash[:toast] = 'SY deleted successfully.'
          redirect_to admin_classes_class_sy_manage_index_path
        end

        def edit
          set_class
          @school_year = @class.school_years.find(params[:id])
        end

        def update
          set_class
          set_sy

          return if dates_valid?

          if @sy.update(update_params)
            update_success
            return
          else
            handle_errors(@sy)
          end

          render :edit, status: :unprocessable_entity
        end

        def create
          set_class
          set_sy

          return if dates_valid?

          if @sy.save
            redirect_to admin_classes_class_sy_manage_index_path
          else
            handle_errors(@sy)
            redirect_to new_admin_classes_class_sy_manage_path
          end
        end

        def show
          set_default_sort(default_sort_column: 'name asc')
          query_items_default(SchoolYear, params)
        end

        private

        def update_success
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_classes_class_sy_manage_index_path
        end

        def set_class
          @class = SchoolClass.find(params[:class_id])
        end

        def set_sy
          @sy = @class.school_years.new school_year_params
        end

        def dates_valid?
          date_present?(school_year_params[:start],
                        school_year_params[:end]) || date_valid?(school_year_params[:start], school_year_params[:end])
        end

        def date_valid?(start_date, end_date)
          start_date = start_date.to_date
          end_date = end_date.to_date

          if end_date < start_date
            flash[:end_error] = 'End date should be later than start date'
            redirect_to new_admin_classes_class_sy_manage_path
            return true
          end

          false
        end

        def date_present?(start_date, end_date)
          start_date = start_date.to_date
          end_date = end_date.to_date

          if start_date.nil? || end_date.nil?
            flash[:start_error] = 'Start date is required' if start_date.nil?
            flash[:end_error] = 'End date is required' if end_date.nil?
            redirect_to new_admin_classes_class_sy_manage_path

            return true
          end

          false
        end

        def update_params
          permitted_params = params.require(:school_year).permit(:name, :start, :end)

          # Convert the start and end parameters to Date objects if they are present
          permitted_params[:start] = permitted_params[:start].to_date if permitted_params[:start].present?
          permitted_params[:end] = permitted_params[:end].to_date if permitted_params[:end].present?

          # Return the modified parameters
          permitted_params
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
end
