# frozen_string_literal: true

module Admin
  class SectionsController < Admin::LayoutController
    include ExportableFormatConcern
    include SearchableConcern
    include SnapshotConcern
    include SectionManageable

    before_action :set_section, only: %i[show edit update destroy archive]
    before_action :set_search, only: %i[index new create edit update]

    def index
      @sections = @q.result(distinct: true).page(params[:page]).per(10)
      @count = params[:q].present? ? @sections.count : Section.count
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
        redirect_to admin_sections_path, notice: 'Section was successfully created.'
      else
        redirect_to new_section_admin_path, notice: 'Failed to create section.'
      end
    end

    def update
      return section_not_found if @section.nil?

      if @section.update(update_section_params)
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_sections_path
      else
        render :edit
      end
    end

    def destroy
      @section.destroy
      redirect_to admin_sections_path, notice: 'Section was successfully destroyed.'
    end

    def archive
      @section.archive
      redirect_to admin_sections_path, notice: 'Section was successfully archived.'
    end

    def export
      @section_fields = Section.get_export_fields
    end

    def send_exports
      send_format(params)
    end

    def history
      set_default_sort(default_sort_column: 'created_at desc')
      @q = PaperTrail::Version.ransack(params[:q])
      @items = @q.result(distinct: true).where(item_type: 'Section').page(params[:page]).per(10)
      @count = @items.count
      @sort_fields = get_sort_fields(PaperTrail::Version)
    end

    def version
      set_default_sort(default_sort_column: 'created_at desc')
      @q = PaperTrail::Version.ransack(params[:q])
      @items = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id)).page(params[:page]).per(10)
      @count = @items.count
      @sort_fields = get_sort_fields(PaperTrail::Version)
    end

    def snapshot
      @version = PaperTrail::Version.find(params[:id])
      @section = Section.find(@version.item_id)
    end

    def rollback
      @version = PaperTrail::Version.find(params[:id])
      @section = Section.find(@version.item_id)

      if @section.save(validate: false)
        redirect_to admin_sections_versions_path(id: @version.item_id)
      else
        flash[:toast] = 'Rollback Unsuccessful'
        render :snapshot
      end
    end

    private

    def set_search
      @q = Section.ransack(params[:q])
      @sort_fields = {
        'Name': 'name asc',
        'Description': 'description asc',
        'Created At': 'created_at asc',
        'Updated At': 'updated_at asc'
      }
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
