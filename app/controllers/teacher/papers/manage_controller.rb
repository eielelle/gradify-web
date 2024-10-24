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

      def student_exam_overviews
        @teacher = current_user
        @subject = @teacher.subjects.find(params[:id])
        @exam = @subject.exams.find(params[:exam_id])
        @student = User.find(params[:student_id])
        
        # Fetch the answer key from the exam
        @answer_key = @exam.answer_key
        
        # Commented out the fetching of student's answers for now
        # @student_answers = @student.exam_results.where(exam: @exam).pluck(:answers).first
        
        # Initialize arrays to store analysis data
        # @average_correct = []
        # @difficulty_index = []
        # @discrimination_index = []
        
        # Fetch all students who took the exam for future item analysis
        # all_students = @exam.students
        
        # Example of item analysis logic for future use
        # (1..@answer_key.size).each do |item|
        #   total_students = all_students.count
        #   correct_answers = all_students.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
          
        #   # Calculate average correct percentage for this item
        #   @average_correct[item - 1] = (correct_answers.to_f / total_students) * 100
          
        #   # Calculate Difficulty Index
        #   @difficulty_index[item - 1] = correct_answers.to_f / total_students
          
        #   # Split students into upper and lower groups based on scores
        #   upper_group = all_students.sort_by(&:score).last(total_students / 2)
        #   lower_group = all_students.sort_by(&:score).first(total_students / 2)
          
        #   upper_correct = upper_group.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
        #   lower_correct = lower_group.select { |s| s.exam_results.where(exam: @exam).pluck(:answers)[0][item - 1] == @answer_key[item - 1] }.count
          
        #   # Calculate Discrimination Index (upper group correct - lower group correct)
        #   @discrimination_index[item - 1] = (upper_correct - lower_correct).to_f / (total_students / 2)
        # end
      end
      
      

    end
  end
end
