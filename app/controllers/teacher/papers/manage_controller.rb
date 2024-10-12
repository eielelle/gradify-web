# frozen_string_literal: true

module Teacher
  module Papers
    class ManageController < Teacher::LayoutController
      before_action :authenticate_user!
      
      def index
        @teacher = current_user

        @subjects = @teacher.subjects.includes(:school_classes) # Fetch the subjects and related school classes

        @assignments = @teacher.school_sections
                       .includes(school_year: { school_class: :subjects })
                       .group_by { |section| section.school_year.school_class.subjects }
      end

      def show
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])
        @exams = @subject.exams.includes(:subject)
      end

      def exam_details
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])  # Fetch the specific subject based on the teacher's assignment
        @exam = @subject.exams.find(params[:exam_id])   # Fetch the exam associated with the subject
      
        # Fetch students based on the subject and school section they are assigned to
        @students = User.joins(:school_sections, :subjects)
                        .where(role: 'student')
                        .where(school_sections: { id: @teacher.school_section_ids }) # Sections that are taught by this teacher
                        .where(subjects: { id: @subject.id }) # Ensure the subject matches
                        .distinct
      
        # Handle case where no students are found
        if @students.empty?
          flash.now[:alert] = "No students found for this exam and subject combination."
        end
      end
      

    end
  end
end
