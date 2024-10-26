module Teacher
    module Grades
      class ExportController < Teacher::LayoutController
        include ExportableFormatConcern
  
        def index
          @teacher = current_user
          @subjects = @teacher.subjects.includes(:exams)
          @export_fields = [
            'student_name',
            'student_email',
            'class',
            'section',
            'subject',
            'exam_scores',
            'average_score'
          ]
        end
  
        def download
          send_format params
        end
  
        private
  
        def send_format(params)
          selected_fields = params[:selected_fields].to_a
          no_header = params[:no_header]
          date = formatted_date
          format, method = detect_format_and_method(params)
  
          return unless format && method
  
          # Get the data
          teacher = current_user
          students = User.joins(:school_sections, :subjects)
                        .where(role: 'student')
                        .where(school_sections: { id: teacher.school_section_ids })
                        .where(subjects: { id: teacher.subjects.pluck(:id) })
                        .distinct
          
          # Generate CSV data
          csv_data = generate_csv(students, selected_fields, no_header)
          
          send_data csv_data, filename: "gradebook_export_#{date}.#{format}"
        end
  
        def generate_csv(students, fields, no_header)
          CSV.generate(headers: !no_header) do |csv|
            csv << fields unless no_header
  
            students.each do |student|
              student.subjects.each do |subject|
                row_data = []
                fields.each do |field|
                  row_data << case field
                             when 'student_name' then student.name
                             when 'student_email' then student.email
                             when 'class' then 
                               student.school_sections.map { |section| 
                                 section.school_year.school_class.name 
                               }.uniq.join(", ")
                             when 'section' then student.school_sections.map(&:name).join(", ")
                             when 'subject' then subject.name
                             when 'exam_scores'
                               exams = Exam.where(subject: subject)
                               exams.map { |exam| "#{exam.name}: 0" }.join("; ")
                             when 'average_score' then "0"
                             end
                end
                csv << row_data
              end
            end
          end
        end
      end
    end
  end