# frozen_string_literal: true

module Teacher
  module Grades
    class ManageController < Teacher::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(Exam, params)

        @teacher = current_user
        
        # Get all subjects taught by the teacher
        @subjects = @teacher.subjects.includes(:exams)
        
        # Get all students in the teacher's sections and subjects
        @students = User.joins(:school_sections, :subjects)
                       .where(role: 'student')
                       .where(school_sections: { id: @teacher.school_section_ids })
                       .where(subjects: { id: @subjects.pluck(:id) })
                       .distinct
                       .includes(:school_sections, :subjects)
        
        # Get all exams for the teacher's subjects
        @exams = Exam.where(subject_id: @subjects.pluck(:id))
      end
    end
  end
end
