module Admin
    module Admins
        class HistoryController < Admin::LayoutController
            include SearchableConcern
            include SnapshotConcern
        
            def versions
              set_default_sort(default_sort_column: 'created_at desc')
              @q = PaperTrail::Version.ransack(params[:q])
              @items = @q.result(distinct: true).where(item_id: params[:id] || params.dig(:q, :id)).page(params[:page]).per(10)
              @count = @items.count
              @sort_fields = get_sort_fields(PaperTrail::Version)
            end
        
            def snapshot
              @version = PaperTrail::Version.find(params[:id])
        
              @admin = get_snapshot(@version)
            end
        
            def rollback
              @version = PaperTrail::Version.find(params[:id])
        
              @admin = get_snapshot(@version)
        
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
        end
    end
end