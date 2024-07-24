# frozen_string_literal: true

module Admin
  class SectionsController < Admin::LayoutController
    before_action :set_section, only: %i[show edit update destroy archive]
    before_action :set_search, only: %i[index new create edit update]
    include ExportableFormatConcern
    def index
      # Your index method code here
      @sections = @q.result(distinct: true).page(params[:page]).per(10)
      @count = params[:q].present? ? @sections.count : Section.count
    end

    def show
      # Your new method code here
    end

    def new
      # Your new method code here
      @section = Section.new
      @q = Section.ransack(params[:q])
    end

    def edit
      set_section
    end

    def create
      # Your create method code here
      @section = Section.new(section_params)

      if @section.save
        redirect_to admin_sections_path, notice: 'Section was successfully created.'
      else
        redirect_to new_section_admin_path, notice: 'Failed to create section.'
      end
    end

    def update
      set_section

     return section_not_found if @section.nil?

      if @section.update(update_section_params[:section])
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_sections_path
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

    def export
      @section_fields = Section.get_export_fields
    end

    def send_exports
      send_format params
    end

    private

    def set_section
      @section = Section.find(params[:id])
    end

    def section_params
      params.permit(:name, :description, :archived)
    end

    def update_section_params
      params.permit(:id, section: %i[name description archived])
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

    def section_not_found
      flash[:notice] = 'Section not found.'
      redirect_to admin_sections_path
    end

    def send_format(params)
      sections = params[:selected_sections].to_a || []
      no_header = params[:no_header]
      date = formatted_date
      format, method = detect_format_and_method(params)

      return unless format && method

      send_data Section.send(method, { sections:, no_header: }), filename: "#{date}.#{format}"
    end
  end
end
