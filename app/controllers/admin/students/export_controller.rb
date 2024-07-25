# app/controllers/admin/students/export_controller.rb
# frozen_string_literal: true

require 'csv'

module Admin
  module Students
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @student_accounts = StudentAccount.all
        @student_fields = StudentAccount.column_names - ['id', 'created_at', 'updated_at', 'encrypted_password', 'reset_password_token', 'reset_password_sent_at', 'remember_created_at'] # Exclude fields you don’t want
        respond_to do |format|
          format.html
          format.csv { send_data @student_accounts.to_csv, filename: "student_accounts-#{Date.today}.csv" }
        end
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

        send_data StudentAccountAccount.send(method, { admins:, permissions:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
