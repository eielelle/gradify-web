# frozen_string_literal: true

module Admin
  module Students
    class HistoryController < Admin::LayoutController
      include SnapshotConcern
      include SearchableConcern
      include SortConcern

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @items = @q.result(distinct: true).where(item_type: 'StudentAccount').page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

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
        @version = PaperTrail::Version.find(params[:id])
        @student = get_snapshot(@version)
      end

      def rollback
        @version = PaperTrail::Version.find(params[:id])

        @student = @version.reify

        if @student.save(validate: false)
          redirect_to admin_students_versions_path(id: @version.item_id), notice: 'Rollback successful.'
        else
          flash[:toast] = 'Rollback Unsuccessful'
          render :snapshot
        end
      end
    end
  end
end
