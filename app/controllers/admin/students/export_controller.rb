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

      def import
        skips = 0;
        users_data = CSV.read(params[:csv_file].path, headers: true)

        users_data.each do |row|
          puts row.inspect
          puts row['first_name']
          @student_account = User.new(name: "#{row['first_name']} #{row['middle_name']} #{row['last_name']}", first_name: row['first_name'], middle_name: row['middle_name'], last_name: row['last_name'], email: row['email'], role: 'student')

          @strand = SchoolClass.find_by(name: row['strand'])
          if @strand.nil?
            # skips += 1;
          else
            @section = strand.school_sections.find_by(name: row['section'])
            @subjects = Subject.where(school_class_id: @strand.id)
          end
          
          if @student_account.save
            acc = User.find(@student_account.id)

            if @strand.nil? && @section.nil? && @subjects.nil?
              # sa
            else
              @section.users << acc unless @sections.users.include?(acc)
              @subjects.each do |subject|
                subject.users << acc unless subject.users.include?(acc)
              end
            end
          else
            puts @student_account.errors.full_messages
            skips = skips + 1
          end
        end

        flash[:toast] = "Imported CSV. #{skips} row skipped."
        redirect_to admin_students_export_path
      end
    end
  end
end
