# frozen_string_literal: true

require 'csv'

module Admin
  module Classes
    module Sy
      class ExportController < Admin::LayoutController
        include ExportableFormatConcern

        def index
          @sy_fields = SchoolYear.get_export_fields(%i[school_class_id])
        end

        def download
          send_format params
        end

        def send_format(params)
          @class = SchoolClass.find params[:class_id]
          sy = params[:selected_sy].to_a || []
          no_header = params[:no_header]
          date = formatted_date
          format, method = detect_format_and_method(params)

          return unless format && method

          send_data @class.school_years.send(method, { sy:, no_header: }),
                    filename: "#{date}.#{format}"
        end
      end
    end
  end
end
