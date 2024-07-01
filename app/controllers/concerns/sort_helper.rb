# frozen_string_literal: true

module SortHelper
  extend ActiveSupport::Concern

  def get_sort_fields(model)
    model.ransackable_attributes(nil).flat_map do |attr|
      [
        ["#{attr.titleize} ↑", "#{attr} asc"],
        ["#{attr.titleize} ↓", "#{attr} desc"]
      ]
    end
  end
end
