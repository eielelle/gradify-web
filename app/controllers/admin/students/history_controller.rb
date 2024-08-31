# frozen_string_literal: true

module Admin
  module Students
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern

      def versions
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @results = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id),
                                                   item_type: 'StudentAccount')
        @items = @results.page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def snapshot
        find_version_and_snapshot
      end

      def rollback
        find_version_and_snapshot

        PaperTrail.request.whodunnit = current_admin_account.name
        @student.paper_trail_event = 'rollback'

        if @student.save(validate: false)
          redirect_to admin_students_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        query_items_history(PaperTrail::Version, params, model_name: 'StudentAccount')
      end

      private

      def find_version_and_snapshot
        @version = PaperTrail::Version.find(params[:id])
        @student = get_snapshot(@version)
      end
    end
  end
end
