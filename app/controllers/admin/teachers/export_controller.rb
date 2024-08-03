# frozen_string_literal: true

module Admin
  module Teachers
    class ExportController < Admin::LayoutController
      include ExportableFormatConcern

      def index
        @teacher_fields = TeacherAccount.get_export_fields(%i[encrypted_password reset_password_token])
      end

      def download
        send_format params
      end

      def send_format(params)
        teachers = params[:selected_teachers].to_a || []
        no_header = params[:no_header]
        date = formatted_date
        format, method = detect_format_and_method(params)

        return unless format && method

        send_data TeacherAccount.send(method, { teachers:, no_header: }),
                  filename: "#{date}.#{format}"
      end
    end
  end
end
