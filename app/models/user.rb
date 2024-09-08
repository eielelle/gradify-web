class User < ApplicationRecord
  include Exportable

  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
  current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

  validates :name, presence: true
  validates :role, presence: true

  enum role: { superadmin: 'superadmin', admin: 'admin', teacher: 'teacher', student: 'student' }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:users].map { |user| "user_#{user}" }
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
    fields[:users].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      fields[:users].index_with { |field| record.send(field) }
    end
  end
end
