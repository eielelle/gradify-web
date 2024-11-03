# frozen_string_literal: true

module Teacher
  class OverviewController < Teacher::LayoutController
    def index
      
      # Get total classes assigned to the current teacher
      @total_classes = SchoolClass.joins(school_sections: :users)
                                  .where(users: { id: current_user.id, role: 'teacher' })
                                  .distinct
                                  .count
      
      # Count total students associated with the sections assigned to the teacher's classes
      @total_students = User.joins(:school_sections)
                            .where(school_sections: { id: current_user.school_sections.ids }, role: 'student')
                            .distinct
                            .count

      # Count exams for subjects assigned to the teacher
      @total_exams = Exam.joins(:subject)
                         .where(subject: { id: current_user.subject_ids })
                         .distinct
                         .count

      # Count subjects assigned to the current teacher
      @total_subjects = current_user.subjects.distinct.count
    
    end
  end
end
