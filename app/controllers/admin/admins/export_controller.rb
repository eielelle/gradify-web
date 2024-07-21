# frozen_string_literal: true

require 'csv'

module Admin
  module Admins
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @admin_fields = AdminAccount.get_export_fields(%i[encrypted_password reset_password_token
                                                          permission_id])
        @permission_fields = Permission.get_export_fields
      end

      def download
        send_format params
      end

      def send_format(params)
        admins = params[:selected_admins].to_a || []
        permissions = params[:selected_permissions].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data AdminAccount.send(method, { admins:, permissions:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
