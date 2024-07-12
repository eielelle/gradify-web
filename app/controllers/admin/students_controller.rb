# frozen_string_literal: true

module Admin
  class StudentsController < ApplicationController
    before_action :set_student, only: %i[show edit update destroy]

    def index
      @q = StudentAccount.ransack(params[:q])
      @students = @q.result(distinct: true).page(params[:page])
      @count = @students.total_count
      @sort_fields = {
        'Name': 'name asc',
        'Email': 'email asc',
        'Created At': 'created_at asc',
        'Updated At': 'updated_at asc'
      }
    end

    def show; end

    def new
      @student = StudentAccount.new
    end

    def edit; end

    def create
      @student = StudentAccount.new(student_params)

      if @student.save
        redirect_to admin_students_path, notice: 'Student was successfully created.'
      else
        render :new
      end
    end

    def update
      if @student.update(student_params)
        redirect_to admin_students_path, notice: 'Student was successfully updated.'
      else
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
  end
end
