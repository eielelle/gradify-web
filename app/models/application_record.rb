# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

class PaperTrail::Version < ActiveRecord::Base
  # Allow only these attributes to be searchable
  def self.ransackable_attributes(auth_object = nil)
    %w[id item_type item_id event whodunnit created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end