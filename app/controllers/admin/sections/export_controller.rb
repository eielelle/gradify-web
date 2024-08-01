# frozen_string_literal: true

require 'csv'

module Admin
    module Sections
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern
      
      def index
        @section_fields = Section.get_export_fields
      end
  
      def download
        send_format params
      end
  
      def send_format(params)
        sections = params[:selected_sections].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)
  
        return unless format && method
  
        send_data Section.send(method, { sections:, no_header: }), filename: "#{date}.#{format}"
      end
    end
  end
end
  