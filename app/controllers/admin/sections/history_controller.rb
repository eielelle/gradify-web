# frozen_string_literal: true

module Admin
  module Sections
    class HistoryController < Admin::LayoutController
      include SnapshotConcern
      include SearchableConcern
      include SortConcern

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @items = @q.result(distinct: true).where(item_type: 'Section').page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def versions
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @result = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q,
                                                                                     :id), item_type: 'Section')
        @items = @result.page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def snapshot
        @version = PaperTrail::Version.find(params[:id])
        @section = Section.find(@version.item_id)
      end

      def rollback
        @version = PaperTrail::Version.find(params[:id])
        @section = Section.find(@version.item_id)

        if @section.save(validate: false)
          redirect_to admin_sections_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
          render :snapshot
        end
      end
    end
  end
end
