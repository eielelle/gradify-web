# frozen_string_literal: true

require 'csv'

module Admin
  module Subjects
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @subject_fields = Subject.get_export_fields()
      end

      def download
        send_format params
      end

      def send_format(params)
        subjects = params[:selected_subjects].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data Subject.send(method, { subjects:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
