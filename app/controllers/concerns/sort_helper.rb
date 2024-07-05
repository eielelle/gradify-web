# frozen_string_literal: true

module SortHelper
  extend ActiveSupport::Concern

  included do
    before_action :set_default_sort
  end

  def get_sort_fields(model)
    model.ransackable_attributes(nil).flat_map do |attr|
      [
        ["#{attr.titleize} ↑", "#{attr} asc"],
        ["#{attr.titleize} ↓", "#{attr} desc"]
      ]
    end
  end

  private

  def set_default_sort
    params[:q] ||= {}
    params[:q][:s] ||= default_sort_column
  end

  def default_sort_column
    'id asc'
  end
end
