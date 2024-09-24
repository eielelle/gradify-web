# frozen_string_literal: true

class Subject < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at description id id_value name updated_at]
  end
end
