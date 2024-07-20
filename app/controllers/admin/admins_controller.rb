# frozen_string_literal: true

require 'csv'

module Admin
  class AdminsController < Admin::LayoutController
    include ExportableFormatConcern
    include SortConcern
    include PaperTrailConcern
    include SearchableConcern
    include SnapshotConcern

    def index
      set_default_sort(default_sort_column: "name asc")
      query_items_default(AdminAccount, params)
    end

    def new
      @permissions = Permission.all
    end

    def create
      permission = Permission.find(admin_params[:permission_id])

      return if permission.nil?

      admin = AdminAccount.new admin_params

      if admin.save
        redirect_to admin_admins_path
      else
        handle_errors(admin)
        redirect_to new_admin_admin_path
      end
    end

    def show
      set_admin
    end

    def destroy
      set_admin
      if @admin.destroy
        flash[:toast] = 'Account deleted successfully.'
        redirect_to admin_admins_path
      end
    end

    def versions
      set_default_sort(default_sort_column: "created_at desc")
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
        redirect_to versions_admin_admins_path(id: @version.item_id)
      else
        flash[:toast] = "Rollback Unsuccessful"
      end
    end

    def history
      set_default_sort(default_sort_column: "created_at desc")
      query_items_history(PaperTrail::Version, params, model_name: "AdminAccount")
    end

    def edit
      set_admin
    end

    def update
      set_admin

      flash[:notice] = 'Account not found.' if @admin.nil?

      if @admin.update(update_admin_params[:admin_account])
        flash[:toast] = 'Updated Successfully.'
        redirect_to admin_admins_path
        return
      else
        handle_errors(@admin)
      end

      render :edit, status: :unprocessable_entity
    end

    def export
      @admin_fields = AdminAccount.get_export_fields(%i[encrypted_password reset_password_token permission_id])
      @permission_fields = Permission.get_export_fields
    end

    def send_exports
      send_format params
    end

    private

    def set_admin
      @admin = AdminAccount.includes(:permission).find(params[:id])
      @permissions = Permission.all
    end

    def send_format(params)
      admins = params[:selected_admins].to_a || []
      permissions = params[:selected_permissions].to_a || []
      no_header = params[:no_header]
      date = formatted_date
      format, method = detect_format_and_method(params)

      return unless format && method

      send_data AdminAccount.send(method, { admins:, permissions:, no_header: }), filename: "#{date}.#{format}"
    end

    # TODO: refactor to module
    def handle_errors(model)
      model.errors.each do |error|
        flash["#{error.attribute}_error"] = "#{error.attribute.capitalize} #{model.errors[error.attribute].first}"
      end
    end

    def admin_params
      params.permit(:name, :email, :permission_id, :password)
    end

    def update_admin_params
      params.permit(:id, admin_account: %i[name email permission_id])
    end
  end
end
