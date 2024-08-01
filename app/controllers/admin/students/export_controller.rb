# frozen_string_literal: true

require 'csv'

module Admin
  module Students
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @student_fields = StudentAccount.get_export_fields(%i[encrypted_password reset_password_token
                                                              permission_id])
        @permission_fields = Permission.get_export_fields
      end

      def download
        send_format params
      end

      def send_format(params)
        students = params[:selected_students].to_a || []
        permissions = params[:selected_permissions].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data StudentAccount.send(method, { students:, permissions:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
