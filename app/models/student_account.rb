# frozen_string_literal: true

class StudentAccount < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at email id name updated_at]
  end
  
  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[permissions]
  end

end
