# frozen_string_literal: true

module SearchableConcern
  extend ActiveSupport::Concern

  include SortConcern

  included do
    attr_reader :q, :items, :count, :sort_fields

    def query_items_history(model_class, params, model_name: model_class.name)
      @q = model_class.ransack(params[:q])

      subquery = model_class.select('DISTINCT ON (item_id) *')
                            .where(item_type: model_name)
                            .order('item_id, created_at DESC')

      @items = model_class.from(subquery, :versions)
                          .merge(@q.result)
                          .page(params[:page])
                          .per(10)
      @count = @items.total_count
      @sort_fields = get_sort_fields(model_class)
    end

    def query_items_default(model_class, params)
      @q = model_class.ransack(params[:q])
      @items = @q.result(distinct: true).page(params[:page]).per(10)
      @count = model_class.count
      @sort_fields = get_sort_fields(model_class)
    end

    def query_items_default_where_id(model_class, params, where_clause = {})
      @q = model_class.ransack(params[:q])
      @items = @q.result(distinct: true).where(where_clause).page(params[:page]).per(10)
      @count = model_class.count
      @sort_fields = get_sort_fields(model_class)
    end
  end
end
