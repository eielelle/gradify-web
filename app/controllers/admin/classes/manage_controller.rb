class Admin::Classes::ManageController < Admin::LayoutController
    include SearchableConcern
    include ErrorConcern
    
    def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(SchoolClass, params)
    end

    def new
        @permissions = Permission.all
      end

      def create
        school_class = SchoolClass.new class_params

        if school_class.save
          redirect_to admin_classes_manage_index_path
        else
          handle_errors(school_class)
          redirect_to new_admin_classes_manage_path
        end
      end

      private

      def class_params
        params.permit(:name, :description)
      end
end