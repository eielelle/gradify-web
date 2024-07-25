# frozen_string_literal: true

module Admin
  module Admins
    class HistoryController < Admin::LayoutController
      include SearchableConcern
      include SnapshotConcern
  
      def versions
        @q = PaperTrail::Version.ransack(params[:q])
        @items = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id)).page(params[:page]).per(10)
        @count = @items.count
        @sort_fields = get_sort_fields(PaperTrail::Version)
      end
  
      def snapshot
        @version = PaperTrail::Version.find(params[:id])
        @student = get_snapshot(@version)
      end
  
      def rollback
        @version = PaperTrail::Version.find(params[:id])
        @student = get_snapshot(@version)
  
        if @student.save(validate: false)
          redirect_to admin_students_versions_path(id: @version.item_id)
        else
          flash[:toast] = 'Rollback Unsuccessful'
        end
      end

      def index
        @history = StudentAccountHistory.all
      end
    end
  end
end
