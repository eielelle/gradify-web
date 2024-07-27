# frozen_string_literal: true

module SectionSearchable
  extend ActiveSupport::Concern

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
