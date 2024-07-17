# frozen_string_literal: true

module Admin
  class SectionsController < ApplicationController
    before_action :set_section, only: %i[show edit update destroy archive]
    def index
      # Your index method code here
      @q = Section.ransack(params[:q])
      @sections = @q.result(distinct: true).page(params[:page])
      @count = @sections.total_count
      @sort_fields = {
        'Name': 'name asc',
        'Description': 'description asc',
        'Created At': 'created_at asc',
        'Updated At': 'updated_at asc'
      }
    end

    def show
      # Your new method code here
    end

    def new
      # Your new method code here
      @section = Section.new
    end

    def edit
      # Your edit method code here
    end

    def create
      # Your create method code here
      @section = Section.new(section_params)

      if @section.save
        redirect_to admin_sections_path, notice: 'Section was successfully created.'
      else
        render :new
      end
    end

    def update
      # Your export method code here
      if @section.update(section_params)
        redirect_to admin_sections_path, notice: 'Section was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      # Your destroy method code here
      @section.destroy
      redirect_to admin_sections_path, notice: 'Section was successfully destroyed.'
    end

    def archive
      # Your archive method code here
      @section.archive
      redirect_to admin_sections_path, notice: 'Section was successfully archived.'
    end

    private

    def set_section
      @section = Section.find(params[:id])
    end

    def section_params
      params.require(:section).permit(:name, :description)
    end
  end
end
