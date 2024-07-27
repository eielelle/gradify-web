# frozen_string_literal: true

module SectionManageable
  extend ActiveSupport::Concern

  def set_section
    @section = Section.find(params[:id])
  end

  def section_not_found
    flash[:notice] = 'Section not found.'
    redirect_to admin_sections_path
  end

  def section_params
    params.require(:section).permit(:name, :description, :archived)
  end

  def update_section_params
    params.require(:section).permit(:name, :description, :archived)
  end
end
