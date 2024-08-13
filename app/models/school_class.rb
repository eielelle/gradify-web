class SchoolClass < ApplicationRecord
    include Exportable

    validates :name, presence: true

    # TODO: Refactor this to a modular approach
    def self.to_csv(fields)
        headers = fields[:no_header].present?

        CSV.generate(headers:) do |csv|
            add_headers(csv, fields) unless headers
            add_records(csv, fields)
        end
    end

    def self.to_xml(fields)
        serial_data(fields).to_xml
    end

    def self.to_json(fields)
        serial_data(fields).to_json
    end

    def self.csv_row(fields, record)
        return fields[:classes].map { |field| record.send(field) }
    end

    def self.serial_data(fields)
        all.map do |record|
            class_data = fields[:classes].index_with { |field| record.send(field) }

            class_data
        end
    end

    def self.ransackable_attributes(_auth_object = nil)
        get_export_fields(%i[description])
    end
    
    # Allowlist associations for Ransack
    def self.ransackable_associations(_auth_object = nil)
        %w[]
    end

    def self.add_headers(csv, fields)
        csv << fields[:classes].map(&:to_s)
    end

    def self.add_records(csv, fields)
        all.find_each do |record|
            csv << csv_row(fields, record)
        end
    end
end
