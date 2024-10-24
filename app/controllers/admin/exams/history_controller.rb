# frozen_string_literal: true

module Admin
  module Exams
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern

      def versions
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @results = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q,
                                                                                      :id), item_type: 'Exam')
        @items = @results.page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = set_sort_fields(%w[created_at event whodunnit])
      end

      def snapshot
        find_version_and_snapshot
      end

      def rollback
        find_version_and_snapshot

        PaperTrail.request.whodunnit = current_exam.name
        @exam.paper_trail_event = 'rollback'

        if @exam.save(validate: false)
          redirect_to admin_workforce_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        query_items_history(PaperTrail::Version, params, model_name: 'Exam')

        @sort_fields = set_sort_fields(%w[
                                         created_at
                                         event
                                         whodunnit
                                       ])
      end

      private

      def find_version_and_snapshot
        @version = PaperTrail::Version.find(params[:id])
        @exam = get_snapshot(@version)

        Rails.logger.debug @exam.inspect
      end
    end
  end
end
