# frozen_string_literal: true

class SchoolSection < ApplicationRecord
  include Exportable
  # belongs_to :school_class
  # has_many :users, dependent: :nullify

  belongs_to :school_year
  has_and_belongs_to_many :users

  validates :name, presence: true

  has_paper_trail ignore: %i[created_at updated_at]

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
    fields[:sections].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      sections_data = fields[:sections].index_with { |field| record.send(field) }

      sections_data
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    get_export_fields(%i[school_class_id])
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:sections].map(&:to_s)
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
