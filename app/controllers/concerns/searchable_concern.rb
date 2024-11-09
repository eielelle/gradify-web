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

    def query_items_type(item_type)
      @q = PaperTrail::Version.ransack(params[:q])
      @results = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id),
                                                 item_type:)
      @items = @results.page(params[:page]).per(10)
      paginate_and_sort(@items, PaperTrail::Version)
    end

    def query_items_default(model_class, params)
      @q = model_class.ransack(params[:q])
      @items = @q.result(distinct: true).page(params[:page]).per(10)
      paginate_and_sort(model_class, model_class)
    end

    def query_items_wf(model_class, params)
      @q = model_class.ransack(params[:q])
    
      if current_user.role == "superadmin"
        @items = @q.result(distinct: true).where.not(role: 'student').page(params[:page]).per(10)
      elsif current_user.role == "admin"
        @items = @q.result(distinct: true).where(role: 'teacher').page(params[:page]).per(10)
      end
      paginate_and_sort(@items, model_class)
    end
  end

  private

  def paginate_and_sort(items, sort_fields)
    @count = items.count
    @sort_fields = get_sort_fields(sort_fields)
  end
end
