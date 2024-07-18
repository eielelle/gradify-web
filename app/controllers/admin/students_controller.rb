# frozen_string_literal: true

module Admin
  class StudentsController < Admin::LayoutController
    before_action :set_student, only: %i[show edit update destroy]
    before_action :set_search, only: %i[index new create edit update]
    include ExportableFormatConcern

    def index
      @students = @q.result(distinct: true).page(params[:page])
      @count = @students.total_count
    end

    def show; end

    def new
      @student_account = StudentAccount.new
      @q = StudentAccount.ransack(params[:q])
    end

    def edit
      set_student
    end

    def create
      @student_account = StudentAccount.new(student_params)
      if @student_account.save
        redirect_to admin_students_path, notice: 'Student account created successfully.'
      else
        errors_student_name(@student_account)
        errors_student_email(@student_account)
        errors_student_password(@student_account)
        render :new
      end
    end

    def update
      set_student

      flash[:notice] = 'Account not found.' if @student.nil?

      if @student.update(update_student_params[:student_account])
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_students_path
        return
      else
        errors_student_name(@student_account)
        errors_student_email(@student_account)
        errors_student_password(@student_account)
      end
      render :edit, status: :unprocessable_entity
    end

    def destroy
      @student.destroy
      redirect_to admin_students_path, notice: 'Student was successfully destroyed.'
    end

    def export
      @student_fields = StudentAccount.get_export_fields(%i[encrypted_password reset_password_token])
    end

    def send_exports
      send_format params
    end

    private

    def set_student
      @student = StudentAccount.includes(:permission).find(params[:id])
      @permissions = Permission.all
    end

    def student_params
      params.require(:student_account).permit(:name, :email, :password, :password_confirmation)
    end

    def update_student_params
      params.permit(:id, student_account: %i[name email permission_id])
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

    def errors_student_name(record)
      flash.now[:name_error] = record.errors[:name].first if record.errors[:name].present?
    end

    def errors_student_email(record)
      flash.now[:email_error] = record.errors[:email].first if record.errors[:email].present?
    end

    def errors_student_password(record)
      flash.now[:password_error] = record.errors[:password].first if record.errors[:password].present?
    end

    def handle_errors(model)
      model.errors.each do |error|
        flash["#{error.attribute}_error"] = "#{error.attribute.capitalize} #{model.errors[error.attribute].first}"
      end
    end

    def send_format(params)
      students = params[:selected_students].to_a || []
      no_header = params[:no_header]
      date = formatted_date
      format, method = detect_format_and_method(params)

      return unless format && method

      send_data StudentAccount.send(method, { students:, no_header: }), filename: "#{date}.#{format}"
    end
  end
end
