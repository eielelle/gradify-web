# frozen_string_literal: true

class SchoolYear < ApplicationRecord
  include Exportable

  belongs_to :school_class

  validates :name, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    get_export_fields(%i[])
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end
end
