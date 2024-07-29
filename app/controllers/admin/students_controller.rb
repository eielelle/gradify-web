# frozen_string_literal: true

module Admin
  class StudentsController < Admin::LayoutController
    before_action :set_student, only: %i[show edit update destroy]
    before_action :set_search, only: %i[index new create edit update]
    include ExportableFormatConcern
    include SearchableConcern
    include SnapshotConcern

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

      return student_not_found if @student.nil?

      if @student.update(update_student_params[:student_account])
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_students_path
      else
        handle_update_errors
      end
    end

    def destroy
      @student.destroy
      redirect_to admin_students_path, notice: 'Student was successfully destroyed.'
    end

    #Export
    def export
      @student_fields = StudentAccount.get_export_fields(%i[encrypted_password reset_password_token])
    end

    def send_exports
      send_format params
    end

    #History
    def history
      set_default_sort(default_sort_column: 'created_at desc')
      @q = PaperTrail::Version.ransack(params[:q])
      @items = @q.result(distinct: true).where(item_type: 'StudentAccount').page(params[:page]).per(10)
      @count = @items.count
      @sort_fields = get_sort_fields(PaperTrail::Version)
    end

    def versions
      set_default_sort(default_sort_column: 'created_at desc')
      @q = PaperTrail::Version.ransack(params[:q])
      @items = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id)).page(params[:page]).per(10)
      @count = @items.count
      @sort_fields = get_sort_fields(PaperTrail::Version)
    end

    def snapshot
      @version = PaperTrail::Version.find(params[:id])
      @student = StudentAccount.find(@version.item_id)
    end

    def rollback
      @version = PaperTrail::Version.find(params[:id])
      @student = StudentAccount.find(@version.item_id)

      if @student.save(validate: false)
        redirect_to admin_students_versions_path(id: @version.item_id)
      else
        flash[:toast] = 'Rollback Unsuccessful'
        render :snapshot
      end
    end
    
    private

    def set_student
      @student = StudentAccount.includes(:permission).find(params[:id])
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

    def student_not_found
      flash[:notice] = 'Account not found.'
      redirect_to admin_students_path
    end

    def handle_update_errors
      errors_student_name(@student_account)
      errors_student_email(@student_account)
      errors_student_password(@student_account)
      render :edit, status: :unprocessable_entity
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
