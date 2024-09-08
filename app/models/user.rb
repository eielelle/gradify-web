class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

  validates :name, presence: true
  validates :role, presence: true

  enum role: { superadmin: 'superadmin', admin: 'admin', teacher: 'teacher', student: 'student' }
end
