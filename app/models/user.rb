class User < ApplicationRecord
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
end
