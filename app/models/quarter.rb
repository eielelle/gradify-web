# frozen_string_literal: true

class Quarter < ApplicationRecord
  include Exportable
  belongs_to :school_year

  validates :name, presence: true

  def self.to_csv(fields)
    headers = fields[:no_header].present?

    CSV.generate(headers:) do |csv|
      add_headers(csv, fields) unless headers
      add_records(csv, fields)
    end
  end

  def self.to_xml(fields)
    serial_data(fields).to_xml
  end

  def self.to_json(fields)
    serial_data(fields).to_json
  end

  def self.csv_row(fields, record)
    fields[:quarters].map { |field| record.send(field) }
  end
  
  def self.serial_data(fields)
    all.map do |record|
      quarter_data = fields[:quarters].index_with { |field| record.send(field) }

      quarter_data
    end
  end
end
