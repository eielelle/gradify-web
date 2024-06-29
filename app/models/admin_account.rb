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
  def self.to_csv(fields, headers = true)
    CSV.generate(headers: headers) do |csv|
      csv << fields[:admins] + fields[:permissions]
  
      all.each do |record|
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
  
  private
  
  def self.csv_row(fields, record)
    admin_data = fields[:admins].map { |field| record.send(field) }
    permission_data = record.permissions.flat_map do |permission|
      fields[:permissions].map { |field| permission.send(field) }
    end
  
    admin_data + permission_data
  end

  def self.serial_data(fields)
    records_array = all.map do |record|
      admin_data = fields[:admins].each_with_object({}) do |field, hash|
        hash[field] = record.send(field)
      end
  
      permissions_data = record.permissions.map do |permission|
        fields[:permissions].each_with_object({}) do |field, hash|
          hash[field] = permission.send(field)
        end
      end
  
      admin_data.merge(permissions: permissions_data)
    end
  end

end
