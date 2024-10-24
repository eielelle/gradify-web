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
        @subjects = Subject.all

        return if invalid_params?

        # Set a default value for items
        @exam.items = 50

        # Collect all answer parameters
        @exam.answer_key = collect_answers

        return unless answer_validation

        if @exam.save
          flash[:toast] = 'Exam was successfully created.'
          redirect_to admin_exams_manage_index_path
        else
          flash[:error] = @exam.errors.full_messages.join(', ')
          # Render with existing answers, subject, and quarter preserved
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
        @subjects = Subject.all

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
          answer = params["answer_#{i + 1}"]
          answers << (answer || '_') # Use underscore for unanswered questions
        end
        answers.join('')
      end

      def invalid_params?
        if params[:exam][:name].blank?
          flash[:toast] = 'Quarter cannot be blank.'
          @exam.answer_key = collect_answers # Preserve answers
          @subjects = Subject.all # Preserve subjects list
          render :new, status: :unprocessable_entity
          return true
        elsif params[:exam][:subject_id].blank?
          flash[:toast] = 'Subject must be selected.'
          @exam.answer_key = collect_answers # Preserve answers
          @subjects = Subject.all # Preserve subjects list
          render :new, status: :unprocessable_entity
          return true
        end
        false
      end

      def answer_validation
        unanswered_items = []
        
        # Loop through the answer key and collect unanswered items
        @exam.answer_key.split('').each_with_index do |answer, index|
          unanswered_items << (index + 1) if answer == '_'
        end
        
        if unanswered_items.any?
          if unanswered_items.length == 50
            flash[:toast] = "Questions 1 to 50 have no answer."
          else
            limited_items = unanswered_items.take(5)  # Limit to 5 items to prevent long message
            remaining_count = unanswered_items.length - limited_items.length
            
            # Generate message
            message = "Item #{limited_items.join(', ')} "
            message += remaining_count > 0 ? "and #{remaining_count} more items have no answer." : "have no answer."
            
            flash[:toast] = message
          end
          
          # Preserve subject and answer_key values
          @subjects = Subject.all
          @exam.answer_key = collect_answers # Preserve answers
          render :new, status: :unprocessable_entity
          return false
        end
        
        true
      end

      def update_success
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_exams_manage_index_path
      end
    end
  end
end
