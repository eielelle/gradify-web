# frozen_string_literal: true

class User < ApplicationRecord
  include Exportable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
                             current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable, :jwt_authenticatable, jwt_revocation_strategy: self

  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :school_sections
  has_and_belongs_to_many :school_classes, through: :school_sections

  validates :name, presence: true
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  enum role: { superadmin: 'superadmin', admin: 'admin', teacher: 'teacher', student: 'student' }

  before_create :generate_student_number, if: :student?
  before_validation :generate_password
  after_create :generate_jti

  def generate_jti
    self.jti = SecureRandom.uuid
    save
  end

  # JWT Revocation Strategy
  def revoke_jwt
    # This method will be called to revoke the JWT
    update(jti: nil)
  end

  def self.revoke_jwt(user)
    user.revoke_jwt
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email student_number updated_at]
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
    role = fields[:role]

    fields[:users].map do |field|
      if role.present?
        record.send(field) if record.role == role
      else
        record.send(field)
      end
    end
  end

  def self.serial_data(fields)
    all.map do |record|
      fields[:users].index_with { |field| record.send(field) }
    end
  end

  attr_writer :login

  def login
    @login || self.student_number || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["lower(student_number) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:student_number) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  private

  def generate_student_number
    loop do
      # Get the last student number or start from 0
      last_number = User.where(role: 'student')
                       .where.not(student_number: nil)
                       .maximum(:student_number)
                       .to_i
      
      # Generate the next number
      next_number = format('%05d', last_number + 1)
      
      # Assign the student number if it's unique
      self.student_number = next_number
      
      # Break the loop if the student number is unique
      break unless User.exists?(student_number: student_number)
    end

    self.password = "#{password}#{self.student_number}".upcase
  end

  def generate_password
    if self.password.nil?
      password = self.last_name
      
      if self.role.upcase == 'STUDENT'
        password = "#{password}_#{self.student_number}".upcase
      else
        password = "#{password}_#{self.role}".upcase
      end
      
      self.password = password
      puts self.password
    end
  end

end