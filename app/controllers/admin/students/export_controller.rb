# frozen_string_literal: true

module Admin
    module Students
      class ExportController < Admin::LayoutController
        include ExportableFormatConcern
  
        def index
          @student_fields = StudentAccount.get_export_fields(%i[encrypted_password reset_password_token])
        end
  
        def send_exports
          send_format params
        end

        def export
        end

        def export
            @students = StudentAccount.all # Adjust query as needed
        
            # Check the format to export
            case params[:csv]
            when 'true'
              respond_to do |format|
                format.csv { send_data generate_csv(@students), filename: "students-#{Date.today}.csv" }
              end
            when 'true'
              respond_to do |format|
                format.json { send_data @students.to_json, filename: "students-#{Date.today}.json" }
              end
            when 'true'
              respond_to do |format|
                format.xml { send_data generate_xml(@students), filename: "students-#{Date.today}.xml" }
              end
            else
              # Handle invalid format
              redirect_to admin_students_manage_path, alert: 'Invalid export format.'
            end
        end
  
        private
  
        def send_format(params)
          students = params[:selected_students].to_a || []
          no_header = params[:no_header]
          date = formatted_date
          format, method = detect_format_and_method(params)
  
          return unless format && method
  
          send_data StudentAccount.send(method, { students:, no_header: }), filename: "#{date}.#{format}"
        end
      end
    end
  end
  