# frozen_string_literal: true

require 'csv'

module Admin
  module Exams
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @exam_fields = Exam.get_export_fields()
      end

      def download
        send_format params
      end

      def send_format(params)
        exams = params[:selected_exams].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data Exam.send(method, { exams:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
