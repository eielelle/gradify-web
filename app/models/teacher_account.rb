class TeacherAccount < ApplicationRecord
  include Exportable

  has_paper_trail ignore: %i[encrypted_password reset_password_token reset_password_sent_at sign_in_count
                             current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable

  validates :name, presence: true




  def self.ransackable_attributes(_auth_object = nil)
    get_export_fields(%i[encrypted_password reset_password_token id reset_password_sent_at remember_created_at])
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

end
