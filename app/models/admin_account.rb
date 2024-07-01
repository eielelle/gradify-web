# frozen_string_literal: true

require 'json'
require 'builder'

class AdminAccount < ApplicationRecord
  include Exportable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

  has_and_belongs_to_many :permissions

  # TODO: Refactor this to a modular approach
  def self.to_csv(fields, headers: true)
    CSV.generate(headers:) do |csv|
      csv << fields[:admins] + fields[:permissions].map { |permission| "permission_#{permission}" }

      all.find_each do |record|
        csv << csv_row(fields, record)
      end
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
    permission_data = record.permissions.flat_map do |permission|
      fields[:permissions].map { |field| permission.send(field) }
    end

    admin_data + permission_data
  end

  def self.serial_data(fields)
    all.map do |record|
      admin_data = fields[:admins].index_with { |field| record.send(field) }

      permissions_data = record.permissions.map do |permission|
        fields[:permissions].index_with do |field|
          permission.send(field)
        end
      end

      admin_data.merge(permissions: permissions_data)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    get_export_fields(%i[encrypted_password reset_password_token id reset_password_sent_at])
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[permissions]
  end
end
