# frozen_string_literal: true

class AdminAccount < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

  has_many :admin_permissions
  has_many :permissions, through: :admin_permissions
end
