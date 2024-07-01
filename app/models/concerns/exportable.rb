# frozen_string_literal: true

require 'csv'

module Exportable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def get_export_fields(excludes = [])
      attribute_names.reject do |attribute|
        excludes.include?(attribute.to_sym) || excludes.include?(attribute.to_s)
      end
    end
  end
end
