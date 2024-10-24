# frozen_string_literal: true

require 'csv'

module Admin
  module Workforce
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @user_fields = User.get_export_fields(%i[encrypted_password reset_password_token reset_password_sent_at
                                                 remember_created_at school_section_id])
      end

      def download
        send_format params
      end

      def send_format(params)
        users = params[:selected_users].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data User.send(method, { users:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
