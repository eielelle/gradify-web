class Admin::Classes::ManageController < Admin::LayoutController
    include SearchableConcern
    
    def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(SchoolClass, params)
    end
end