# frozen_string_literal: true

class TeacherAccount < ApplicationRecord
  include Exportable

  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
                             current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable, :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true

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
    fields[:teachers].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      teacher_data = fields[:teachers].index_with { |field| record.send(field) }

      teacher_data
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    get_export_fields(%i[encrypted_password reset_password_token id reset_password_sent_at remember_created_at])
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:teachers].map(&:to_s)
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
