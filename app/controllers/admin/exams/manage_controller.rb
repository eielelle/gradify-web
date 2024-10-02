# frozen_string_literal: true

module Admin
  module Exams
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      # before_action :authorize_admin

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(Exam, params)
      end

      def new
        @exam = Exam.new
        @subjects = Subject.all
      end

      def create
        @exam = Exam.new(exam_params)
        
        # Set a default value for items
        @exam.items = 50  # or whatever number of items you have
        
        # Collect all answer parameters
        @exam.answer_key = collect_answers
        
        if @exam.save
          redirect_to admin_exams_manage_index_path, notice: 'Exam was successfully created.'
        else
          flash[:error] = @exam.errors.full_messages.join(', ')
          @subjects = Subject.all  # Needed for the form
          render :new, status: :unprocessable_entity
        end
      end

      def show
        set_exam
      end

      def destroy
        set_exam

        if @exam.destroy
          flash[:toast] = 'Exam deleted successfully.'
        else
          handle_errors(@exam)
        end
        redirect_to admin_exams_manage_index_path
      end

      def edit
        set_exam

        redirect_to admin_exams_manage_index_path if @exam.nil?
      end

      def update
        set_exam

        if @exam.update(update_exam_params)
          update_success
        else
          handle_errors(@exam)
          redirect_to edit_admin_exams_manage_path(@exam)
        end
      end

      private

      def set_exam
        @exam = Exam.find(params[:id])
      end

      def exam_params
        params.require(:exam).permit(:name, :subject_id)
      end

      def update_exam_params
        params.require(:exam).permit(:name, :subject_id, :items, :answer_key)
      end

      def collect_answers
        answers = []
        50.times do |i|
          answer = params["answer_#{i+1}"]
          answers << (answer || '_')  # Use underscore for unanswered questions
        end
        answers.join('')
      end

      def update_success
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_exams_manage_index_path
      end
    end
  end
end
