# frozen_string_literal: true

module Admin
  module Classes
    module Sy
      module Sections
        class ManageController < Admin::LayoutController
          include SearchableConcern
          include ErrorConcern

          def index
            set_class
            set_default_sort(default_sort_column: 'name asc')
            query_items_default(@class.school_sections, params)
          end

          def create
            set_class
            set_sc

            if @section.save
              redirect_to admin_classes_class_sy_sections_manage_index_path
            else
              handle_errors(@section)
              redirect_to new_admin_classes_class_sy_sections_manage_path
            end
          end

          def edit
            set_class
            @school_section = @class.school_sections.find(params[:id])
          end

          def update
            set_class
            section = @class.school_sections.find(params[:id])

            if section.update(update_params)
              update_success
              return
            else
              handle_errors(section)
            end

            render :edit, status: :unprocessable_entity
          end

          def destroy
            set_class
            return unless @class.school_sections.find(params[:id]).destroy

            flash[:toast] = 'Section deleted successfully.'
            redirect_to admin_classes_class_sy_sections_manage_index_path
          end

          def show
            set_default_sort(default_sort_column: 'name asc')
            query_items_default(SchoolSection, params)
          end

          def new; end

          private

          def update_success
            flash[:toast] = 'Updated Successfully.'
            redirect_to admin_classes_class_sy_sections_manage_index_path
          end

          def set_class
            @class = SchoolClass.find(params[:class_id])
          end

          def set_sc
            @section = @class.school_sections.new school_section_params
          end

          def update_params
            params.require(:school_section).permit(:name)
          end

          def school_section_params
            params.permit(:name)
          end
        end
      end
    end
  end
end
