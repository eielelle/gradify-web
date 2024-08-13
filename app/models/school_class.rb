class SchoolClass < ApplicationRecord
    include Exportable

    def self.ransackable_attributes(_auth_object = nil)
        get_export_fields(%i[description])
    end
    
    # Allowlist associations for Ransack
    def self.ransackable_associations(_auth_object = nil)
        %w[]
    end
end
