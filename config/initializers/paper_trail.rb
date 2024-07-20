# rubocop:disable Rails/ApplicationRecord
module PaperTrail
    class Version < ActiveRecord::Base
      # Allow only these attributes to be searchable
      def self.ransackable_attributes(_auth_object = nil)
        %w[id item_type item_id event whodunnit created_at]
      end
  
      def self.ransackable_associations(_auth_object = nil)
        []
      end
    end
  end
  