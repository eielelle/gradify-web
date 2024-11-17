# frozen_string_literal: true

module Admin
  module Students
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      before_action :set_student, only: %i[show edit update destroy destroy_selected]
      before_action :set_search, only: %i[index new create edit update]

      def index
        set_default_sort(default_sort_column: 'name asc')
        @q = User.ransack(params[:q])
        @items = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10)
      end

      def show
        set_student
      end

      def new
        @student_account = User.new
      end

      def edit; end

      def create
        # COMBINE THE NAME FIELDS BEFORE CREATING THE STUDENT
        combined_params = student_params
        combined_params[:name] = combine_name(
          combined_params.delete(:first_name),
          combined_params.delete(:last_name),
          combined_params.delete(:middle_name)
        )
      
        @student_account = User.new(combined_params.merge(role: 'student'))
        
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
          redirect_to edit_admin_students_manage_path(@student, hide: true)
        end
      end

      def destroy
        set_student

        @student.destroy
        redirect_to admin_students_manage_index_path, notice: 'Student was successfully destroyed.'
      end

      def destroy_selected
        if params[:student_ids].present?
          User.where(id: params[:student_ids], role: 'student').destroy_all
          redirect_to admin_students_manage_index_path, notice: 'Selected students were successfully deleted.'
        else
          redirect_to admin_students_manage_index_path, alert: 'No students were selected.'
        end
      end

      private

      def set_student
        @student = User.find_by(id: params[:id], role: 'student')
      end

      def student_params
        params.require(:student_account).permit(:first_name, :last_name, :middle_name, :email, :password, :password_confirmation, :student_number)
      end

      # COMBINE FIRST, MIDDLE, AND LAST NAME
      def combine_name(first_name, last_name, middle_name)
        [first_name, middle_name, last_name].select(&:present?).join(' ')
      end

      def update_student_params
        params.permit(:id, user: %i[name email student_number])
      end

      def set_search
        @q = User.ransack(params[:q])
        @items = @q.result(distinct: true).where(role: 'student').page(params[:page]).per(10)
        @sort_fields = {
          'Name': 'name asc',
          'Student Number': 'student_number asc',
          'Email': 'email asc',
          'Created At': 'created_at asc',
          'Updated At': 'updated_at asc'
        }
      end
    end
  end
end