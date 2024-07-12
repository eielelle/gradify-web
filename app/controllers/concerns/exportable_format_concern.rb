# frozen_string_literal: true

module ExportableFormatConcern
  extend ActiveSupport::Concern

  def formatted_date
    Time.zone.today.strftime('%Y-%m-%d')
  end

  def detect_format_and_method(params)
    formats = { 'csv' => :to_csv, 'json' => :to_json, 'xml' => :to_xml }
    formats.detect { |format, _| params[format].present? }
  end
end
