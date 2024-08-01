# frozen_string_literal: true

module Admin
    module Sections
    class ManageController < Admin::LayoutController
      before_action :set_section, only: %i[show edit update destroy archive]
      before_action :set_search, only: %i[index new create edit update]
  
      def index
        @sections = @q.result(distinct: true).page(params[:page])
        @count = @sections.total_count
      end
  
      def show; end
  
      def new
        @section = Section.new
        @q = Section.ransack(params[:q])
      end
  
      def edit; end
  
      def create
        @section = Section.new(section_params)
  
        if @section.save
          redirect_to admin_sections_manage_index_path, notice: 'Section was successfully created.'
        else
          render :new
        end
      end
  
      def update
        return section_not_found if @section.nil?
  
        if @section.update(update_section_params)
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_sections_manage_index_path
        else
          render :edit
        end
      end
  
      def destroy
        @section.destroy
        redirect_to admin_sections_manage_index_path, notice: 'Section was successfully destroyed.'
      end
  
      def archive
        @section.archive
        redirect_to admin_sections_manage_index_path, notice: 'Section was successfully archived.'
      end


      private

      def set_section
        @section = Section.find(params[:id])
      end
    
      def section_not_found
        flash[:notice] = 'Section not found.'
        redirect_to admin_sections_manage_index_path
      end
    
      def section_params
        params.permit(:name, :description, :archived)
      end
    
      def update_section_params
        params.permit(:name, :description, :archived)
      end
  
      def set_search
        @q = Section.ransack(params[:q])
        @sort_fields = {
          'Name': 'name asc',
          'Description': 'description asc',
          'Created At': 'created_at asc',
          'Updated At': 'updated_at asc'
        }
      end
        end
    end
end
  