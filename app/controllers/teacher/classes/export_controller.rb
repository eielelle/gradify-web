# frozen_string_literal: true

require 'csv'

module Teacher
  module Classes
    class ExportController < Teacher::LayoutController
      include ExportableFormatConcern

      def index
        @teacher = current_user
        @export_fields = [
          'class_name',
          'section_name',
          'school_year',
          'subject'
        ]
        
        # Retrieve classes assigned to the teacher
        @school_classes = SchoolClass
                            .joins(school_sections: :users)
                            .where(users: { id: @teacher.id, role: 'teacher' })
                            .distinct
      end

      def download
        send_format(params)
      end

      private

      def send_format(params)
        selected_fields = params[:selected_fields].to_a
        no_header = params[:no_header] == 'true'
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        # Fetch classes assigned to the teacher
        teacher = current_user
        classes = SchoolClass
                    .joins(school_sections: :users)
                    .where(users: { id: teacher.id, role: 'teacher' })
                    .distinct

        # Generate CSV data
        csv_data = generate_csv(classes, selected_fields, no_header)
        
        send_data csv_data, filename: "class_export_#{date}.#{format}"
      end

      def generate_csv(classes, fields, no_header)
        CSV.generate(headers: !no_header) do |csv|
          csv << fields unless no_header

          classes.each do |school_class|
            school_class.school_sections.each do |section|
              row_data = []
              fields.each do |field|
                row_data << case field
                           when 'class_name' then school_class.name
                           when 'section_name' then section.name
                           when 'school_year' then "#{section.school_year.start} - #{section.school_year.end}"
                           when 'subject' then school_class.subjects.map(&:name).join(", ")
                           end
              end
              csv << row_data
            end
          end
        end
      end

      def formatted_date
        Time.zone.now.strftime('%Y-%m-%d')
      end
    end
  end
end
