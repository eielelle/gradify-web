# frozen_string_literal: true

module SortConcern
  extend ActiveSupport::Concern

  # included do
  #   before_action :set_default_sort
  # end

  def get_sort_fields(model)
    model.ransackable_attributes(nil).flat_map do |attr|
      [
        ["#{attr.titleize} ↑", "#{attr} asc"],
        ["#{attr.titleize} ↓", "#{attr} desc"]
      ]
    end
  end

  def set_default_sort(default_sort_column: 'id asc')
    params[:q] ||= {}
    params[:q][:s] ||= default_sort_column
  end

  # private

  # def default_sort_column
  #   'id asc'
  # end
end
