# frozen_string_literal: true

module Student
    module Exams
      class ManageController < Student::LayoutController
        before_action :authenticate_user!
  
        def index
          @student = current_user
          @subjects_with_exams = @student.subjects.includes(:exams, :school_classes)
        end
  
        def show
          @student = current_user
          @exam = Exam.find(params[:id])
          @subject = @exam.subject
  
          # Fetch exam results for the student
          # Assuming you have an Exams Result model that belongs to both Exam and User
          #@exam_result = @exam.exam_results.find_by(user: @student)
  
          #if @exam_result.nil?
            #flash.now[:alert] = "No exam results found for this exam."
          #else
            #@total_score = @exam_result.total_score
            #@correct_answers = @exam_result.correct_answers
            #@incorrect_answers = @exam_result.incorrect_answers
            #@double_answers = @exam_result.double_answers
           # @no_answers = @exam_result.no_answers
         # end
        end
  
  
        private
  
        def authorize_student
          unless current_user.role == 'student'
            flash[:alert] = "You are not authorized to access this page."
            redirect_to root_path
          end
        end
      end
    end
  end