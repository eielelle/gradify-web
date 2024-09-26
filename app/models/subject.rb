# frozen_string_literal: true

class Subject < ApplicationRecord
  include Exportable
  has_paper_trail

  validates :name, presence: true

  has_many :exams

  def self.ransackable_attributes(_auth_object = nil)
    %w[name description updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:subjects].map { |subject| "subject_#{subject}" }
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end

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
    fields[:subjects].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      fields[:subjects].index_with { |field| record.send(field) }
    end
  end
end