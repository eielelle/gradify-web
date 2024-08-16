module Admin
    module Classes
      module Sections
        class ExportController < Admin::LayoutController
            include ExportableFormatConcern
      
            def index
              @sec_fields = SchoolSection.get_export_fields(%i[quarter_id])
            end
      
            def download
              send_format params
            end
      
            def send_format(params)
                @sec_fields = SchoolSection.find params[:quarter_id]
                sec = params[:selected_sec].to_a || []
                no_header = params[:no_header]
                date = formatted_date
                format, method = detect_format_and_method(params)
        
                return unless format && method
        
                send_data @sec_fields.school_sections.send(method, { sections:, no_header: }),
                          filename: "#{date}.#{format}"
              end
          end
      end
    end
end