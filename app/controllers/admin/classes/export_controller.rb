# frozen_string_literal: true

require 'csv'

module Admin
  module Classes
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @class_fields = SchoolClass.get_export_fields(%i[id description created_at])
      end


      def download
        send_format params
      end

      def send_format(params)
        classes = params[:selected_classes].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data SchoolClass.send(method, { classes:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
