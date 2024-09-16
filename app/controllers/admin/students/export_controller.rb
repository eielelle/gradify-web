# frozen_string_literal: true

require 'csv'

module Admin
  module Students
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @student_fields = User.get_export_fields(%i[encrypted_password reset_password_token reset_password_sent_at remember_created_at sign_in_count last_sign_in_at current_sign_in_at last_sign_in_ip current_sign_in_ip created_at id permission_id role school_section_id])
      end

      def download
        send_format params
      end

      def send_format(params)
        students = params[:selected_students].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data User.send(method, { students:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
