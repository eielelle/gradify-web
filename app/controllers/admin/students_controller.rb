# frozen_string_literal: true

module Admin
  class StudentsController < Admin::LayoutController
    before_action :set_student, only: %i[show edit update destroy]
    before_action :set_search, only: %i[index new create edit update]

    def index
      @students = @q.result(distinct: true).page(params[:page])
      @count = @students.total_count
    end

    def show; end

    def new
      @student_account = StudentAccount.new
      @q = StudentAccount.ransack(params[:q])
    end

    def edit; end

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
      if @student.update(student_params)
        redirect_to admin_students_path, notice: 'Student was successfully updated.'
      else
        errors_student_name(@student_account)
        errors_student_email(@student_account)
        errors_student_password(@student_account)
        render :edit
      end
    end

    def destroy
      @student.destroy
      redirect_to admin_students_path, notice: 'Student was successfully destroyed.'
    end

    private

    def set_student
      @student = StudentAccount.find(params[:id])
    end

    def student_params
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

    def errors_student_name(record)
      flash.now[:name_error] = record.errors[:name].first if record.errors[:name].present?
    end

    def errors_student_email(record)
      flash.now[:email_error] = record.errors[:email].first if record.errors[:email].present?
    end

    def errors_student_password(record)
      flash.now[:password_error] = record.errors[:password].first if record.errors[:password].present?
    end
  end
end
