# app/controllers/admin/students/manage_controller.rb
# frozen_string_literal: true

module Admin
  module Students
    class ManageController < Admin::LayoutController
      before_action :set_student_account, only: %i[show edit update destroy]
      before_action :set_search, only: %i[index new create edit update]
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      def index
        @students = @q.result(distinct: true).page(params[:page])
        @count = @students.total_count
      end

      def show
        @student_account = StudentAccount.find_by(id: params[:id])
        if @student_account.nil?
          redirect_to admin_students_manage_index_path, alert: "Student account not found."
      end
      end

      def new
        @student_account = StudentAccount.new
        @q = StudentAccount.ransack(params[:q])
      end

      def create
        @student_account = StudentAccount.new(student_account_params)
        if @student_account.save
        redirect_to admin_students_manage_index_path, notice: 'Student account created successfully.'
        else
          Rails.logger.debug @student_account.errors.full_messages.to_sentence
          flash.now[:alert] = @student_account.errors.full_messages.to_sentence
          render :new
        end
      end

      def edit
        set_student_account
      end

      def update
        if @student_account.update(student_account_params)
          redirect_to admin_students_manage_index_path, notice: 'Student account was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @student_account.destroy
        redirect_to admin_students_manage_index_path, notice: 'Student account was successfully destroyed.'
      end

      private

      def set_student_account
        @student_account = StudentAccount.find(params[:id])
      end

      def student_account_params
        params.require(:student_account).permit(:name, :email, :password, :password_confirmation)
      end

      def set_search
        @q = StudentAccount.ransack(params[:q])
        @sort_fields = {
          'Name': 'name asc',
          'Email': 'email asc',
          'Created At': 'created_at asc',
          'Updated At': 'updated_at asc'
        }
      end
    end
  end
end
  