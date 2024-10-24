# frozen_string_literal: true

class SchoolClass < ApplicationRecord
  include Exportable

  has_many :subjects, dependent: :destroy
  # belongs_to :subject
  has_many :school_years, dependent: :destroy
  has_many :school_sections, through: :school_years
  has_and_belongs_to_many :users
  # has_and_belongs_to_many :school_sections, dependent: :destroy
  # has_and_belongs_to_many :users, dependent: :nullify
  validates :name, presence: true

  has_paper_trail ignore: %i[created_at updated_at]

  # TODO: Refactor this to a modular approach
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
    fields[:classes].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      class_data = fields[:classes].index_with { |field| record.send(field) }

      class_data
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name created_at updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:classes].map(&:to_s)
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
