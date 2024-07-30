# frozen_string_literal: true

module Admin
  module Admins
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern
      include SuperAdminConcern

      def versions
        set_default_sort(default_sort_column: 'created_at desc')
        @q = PaperTrail::Version.ransack(params[:q])
        @items = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q,
                                                                                    :id)).page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end

      def snapshot
        find_version_and_snapshot
      end

      def rollback
        find_version_and_snapshot

        PaperTrail.request.whodunnit = current_admin_account.name
        @admin.paper_trail_event = 'rollback'

        return if superadmin_redirect(@admin, admin_admins_manage_index_path, 'Cannot rollback Superadmin')

        if @admin.save(validate: false)
          redirect_to admin_admins_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        set_default_sort(default_sort_column: 'created_at desc')
        query_items_history(PaperTrail::Version, params, model_name: 'AdminAccount')
      end

      private

      def find_version_and_snapshot
        @version = PaperTrail::Version.find(params[:id])
        @admin = get_snapshot(@version)
      end
    end
  end
end
