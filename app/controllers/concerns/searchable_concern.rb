module SearchableConcern
    extend ActiveSupport::Concern

    include SortConcern
  
    included do
        attr_reader :q, :items, :count, :sort_fields

        def query_items(model_class, params, model_name: model_class.name)
            @q = model_class.ransack(params[:q])
            @items = @q.result(distinct: true)
                    .where(item_type: model_name)
                    .page(params[:page])
                    .per(10)
            @count = @items.total_count
            @sort_fields = get_sort_fields(model_class)
        end
    end
  end