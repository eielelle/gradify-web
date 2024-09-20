# frozen_string_literal: true

module Admin
  module Classes
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern

      def versions
        set_default_sort(default_sort_column: 'created_at desc')  
        @q = PaperTrail::Version.ransack(params[:q])
        @results = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q,
                                                                                      :id), item_type: 'SchoolClass')
        @items = @results.page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def snapshot
        find_version_and_snapshot
      end

      def rollback
        find_version_and_snapshot

        PaperTrail.request.whodunnit = current_school_class.name 
        @school_class.paper_trail_event = 'rollback'
  
        if @school_class.save(validate: false)
          redirect_to admin_classes_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        query_items_history(PaperTrail::Version, params, model_name: 'SchoolClass')
      end

      private

      def find_version_and_snapshot
        @version = PaperTrail::Version.find(params[:id])
        @school_class = get_snapshot(@version)

        Rails.logger.debug @school_class.inspect
      end
    end
  end
end
