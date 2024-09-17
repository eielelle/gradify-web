# frozen_string_literal: true

module Admin
  module Workforce
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern
      include SuperAdminConcern

      def versions
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @results = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q,
                                                                                      :id), item_type: 'User')
        @items = @results.page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def snapshot
        find_version_and_snapshot
      end

      def rollback
        find_version_and_snapshot

        PaperTrail.request.whodunnit = current_user.name
        @user.paper_trail_event = 'rollback'

        return if superadmin_redirect(@user, admin_workforce_manage_index_path, 'Cannot rollback Superadmin')

        if @user.save(validate: false)
          redirect_to admin_workforce_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        query_items_history(PaperTrail::Version, params, model_name: 'User')
      end

      private

      def find_version_and_snapshot
        @version = PaperTrail::Version.find(params[:id])
        @user = get_snapshot(@version)

        Rails.logger.debug @user.inspect
      end
    end
  end
end
