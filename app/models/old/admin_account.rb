# frozen_string_literal: true

require 'json'
require 'builder'

class AdminAccount < ApplicationRecord
  include Exportable

  belongs_to :permission
  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
                             current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

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
    admin_data = fields[:admins].map { |field| record.send(field) }
    permission_data = fields[:permissions].map { |field| record.permission&.send(field) }

    admin_data + permission_data
  end

  def self.serial_data(fields)
    all.map do |record|
      admin_data = fields[:admins].index_with { |field| record.send(field) }

      permission = record.permission
      if permission
        permissions_data = fields[:permissions].index_with do |field|
          permission.send(field)
        end
      end

      admin_data.merge(permissions: permissions_data)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[permissions]
  end

  def self.add_headers(csv, fields)
    csv << fields[:admins].map { |admin| "admin_#{admin}" } +
           fields[:permissions].map { |permission| "permission_#{permission}" }
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end
end
