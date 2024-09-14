# frozen_string_literal: true

module Admin
  module Students
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      # include PaperTrailConcern

      before_action :set_student, only: %i[show edit update destroy destroy_selected]
      before_action :set_search, only: %i[index new create edit update]

      def index
        set_default_sort(default_sort_column: 'name asc')
        @q = User.ransack(params[:q])
        @items = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10) # Only users with the 'student' role
      end

      def show
        set_student
      end

      def new
        @student_account = User.new
        # @q = User.ransack(params[:q])
      end

      def edit; end

      def create
        @student_account = User.new(student_params.merge(role: 'student'))
        if @student_account.save
          redirect_to admin_students_manage_index_path, notice: 'Student account created successfully.'
        else
          handle_errors(@student_account)
          redirect_to new_admin_students_manage_path
        end
      end

      def update
        if @student.update(update_student_params[:user])
          flash[:toast] = 'Updated Successfully.'
          redirect_to admin_students_manage_index_path
        else
          handle_errors(@student)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        render 'error_page', status: :not_found
        # puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        # @student.destroy
        # redirect_to admin_students_manage_index_path, notice: 'Student was successfully destroyed.'
      end

      def destroy_selected
        if params[:student_ids].present?
          Student.destroy(params[:student_ids]) # Destroy the selected students
          respond_to do |format|
            format.html { redirect_to admin_students_manage_index_path, notice: 'Selected students have been removed.' }
            format.json { head :no_content }
          end
        else
          respond_to do |format|
            format.html { redirect_to admin_students_manage_index_path, alert: 'No students were selected.' }
            format.json { head :unprocessable_entity }
          end
        end
      end

      private

      def set_student
        @student = User.find_by(id: params[:id], role: 'student')
      end

      def student_params
        params.require(:student_account).permit(:name, :email, :password, :password_confirmation)
      end

      def update_student_params
        params.permit(:id, user: %i[name email])
      end

      def set_search
        @q = User.ransack(params[:q])
        @items = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10) # Only users with the 'student' role
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
