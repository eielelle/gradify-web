# frozen_string_literal: true

module Student
    module Exams
      class ManageController < Student::LayoutController
        before_action :authenticate_user!
  
        def index
        end
  
        def show
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