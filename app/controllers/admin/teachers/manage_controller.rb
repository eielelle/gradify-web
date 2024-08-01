class Admin::Teachers::ManageController < Admin::LayoutController
    include SearchableConcern
    include ErrorConcern

    def index
      set_default_sort(default_sort_column: 'name asc')
      query_items_default(TeacherAccount, params)
    end

    def new

    end

    def create
      teacher = TeacherAccount.new teacher_params

      if teacher.save
        redirect_to admin_teachers_manage_index_path
      else
        handle_errors(teacher)
        redirect_to new_admin_teachers_manage_path
      end
    end

    def show
      set_teacher
    end


    def edit
      set_teacher

      redirect_to admin_teachers_manage_index_path if @teacher.nil?
    end

    def update
      set_teacher

      account_not_found and return if @teacher.nil?

      if @teacher.update(update_teacher_params[:teacher_account])
        update_success
        return
      else
        handle_errors(@teacher)
      end

      render :edit, status: :unprocessable_entity
    end

    private

    def set_teacher
      @teacher = TeacherAccount.find(params[:id])
    end

    def update_teacher_params
      params.permit(:id, teacher_account: %i[name email permission_id])
    end

    def account_not_found
      flash[:notice] = 'Account not found.'
      render :edit, status: :unprocessable_entity
    end

    def update_success
      flash[:toast] = 'Updated Successfully.'
      redirect_to admin_teachers_manage_index_path
    end

    def teacher_params
      params.permit(:name, :email, :password)
    end
end
