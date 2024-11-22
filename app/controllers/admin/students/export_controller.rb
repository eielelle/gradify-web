# frozen_string_literal: true

require 'csv'

module Admin
  module Students
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @student_fields = User.get_export_fields(%i[school_section_id encrypted_password reset_password_sent_at
                                                    reset_password_token remember_created_at id sign_in_count current_sign_in_at 
                                                    last_sign_in_at current_sign_in_ip last_sign_in_ip jti subject_id role])
      end

      def download
        send_format params
      end

      def send_format(params)
        users = params[:selected_students].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data User.send(method, { users:, no_header:, role: 'student' }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
