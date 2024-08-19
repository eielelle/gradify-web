# frozen_string_literal: true

class StudentAccount < ApplicationRecord
  include Exportable
  belongs_to :school_class
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :name, presence: true

  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
                             current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

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
    fields[:students].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
     student_data = fields[:students].index_with { |field| record.send(field) }

     school_class = record.school_class
     if school_class
      school_class_data = fields[:classes].index_with do |field|
        school_class.send(field)
      end
    end

      student_data.merge(school_class: school_class_data)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email id name updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[permissions]
  end

  def self.add_headers(csv, fields)
    csv << fields[:students].map { |student| "student_#{student}" }
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
