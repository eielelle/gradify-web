# frozen_string_literal: true

module Admin
  module Students
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern
      before_action :set_student, only: %i[show edit update destroy]
      before_action :set_search, only: %i[index new create edit update]

      def index
        @students = @q.result(distinct: true).page(params[:page])
        @count = @students.total_count
      end

      def show
        set_student
      end

      def new
        @student_account = StudentAccount.new
        @q = StudentAccount.ransack(params[:q])
      end

      def edit; end

      def create
        @student_account = StudentAccount.new(student_params)
        if @student_account.save
          redirect_to admin_students_manage_index_path, notice: 'Student account created successfully.'
        else
          render :new
        end
      end

      def update
        if @student.update(update_student_params[:student_account])
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_students_manage_index_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @student.destroy
        redirect_to admin_students_manage_index_path, notice: 'Student was successfully destroyed.'
      end

      private

      def set_student
        @student = StudentAccount.find(params[:id])
      end

      def student_params
        params.require(:student_account).permit(:name, :email, :password, :password_confirmation)
      end

      def update_student_params
        params.permit(:id, student_account: %i[name email])
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
