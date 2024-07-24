# frozen_string_literal: true

class Section < ApplicationRecord
  include Exportable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :validatable

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
      fields[:sections].index_with { |field| record.send(field) }
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at name description updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.get_export_fields(excluded_fields = [])
    column_names.map(&:to_sym) - excluded_fields
  end

  def self.add_headers(csv, fields)
    csv << fields[:sections].map { |section| "section_#{section}" }
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
