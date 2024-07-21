# frozen_string_literal: true

class Section < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at name description updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
