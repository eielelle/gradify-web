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

    private

    def teacher_params
      params.permit(:name, :email, :password)
    end
end
