# frozen_string_literal: true

require 'csv'

module Teacher
  module Exams
    class ExportController < Teacher::LayoutController
      include ExportableFormatConcern

      def index
        @exam_fields = Exam.get_export_fields
      end

      def download
        @teacher = current_user
        @subjects = @teacher.subjects.includes(:school_class)
        
        # Filter selected exam fields to only include ones from teacher's subjects
        selected_fields = params[:selected_exams].to_a
        if selected_fields.empty?
          flash[:error] = "Please select at least one field to export"
          redirect_to teacher_exams_export_path and return
        end

        # Get exams assigned to teacher
        teacher_exams = Exam.where(subject_id: @subjects.pluck(:id))
        
        if teacher_exams.empty?
          flash[:error] = "No exams available to export"
          redirect_to teacher_exams_export_path and return
        end

        # Handle CSV export
        if params[:csv].present?
          date = formatted_date
          send_data teacher_exams.to_csv({ 
            exams: selected_fields, 
            no_header: params[:no_header] 
          }), filename: "exam_export_#{date}.csv"
        else
          flash[:error] = "Invalid export format"
          redirect_to teacher_exams_export_path
        end
      rescue StandardError => e
        flash[:error] = "Export failed: #{e.message}"
        redirect_to teacher_exams_export_path
      end
    end
  end
end