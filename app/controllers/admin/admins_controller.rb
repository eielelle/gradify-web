# frozen_string_literal: true

require 'csv'

module Admin
  class AdminsController < Admin::LayoutController
    include ExportableFormatConcern
    include SortConcern
    include PaperTrailConcern

    def index
      @q = AdminAccount.ransack(params[:q])
      @admins = @q.result(distinct: true).page(params[:page]).per(10)
      @count = params[:q].present? ? @admins.count : AdminAccount.count
      @sort_fields = get_sort_fields(AdminAccount)
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

    end

    def history
      latest_versions = PaperTrail::Version.where(item_type: 'AdminAccount').select('DISTINCT ON (item_id) *').order('item_id, created_at DESC')
      @versions = Kaminari.paginate_array(latest_versions).page(params[:page]).per(10)
      # @versions = PaperTrail::Version.where(item_type: 'AdminAccount').order(created_at: :desc).page(params[:page]).per(10)
      # # puts current_admin_account

      # @versions.map do |version|
      #   puts "HERE"
      #   puts version.item.versions.last.id
      #   puts version.id
      #   # puts version.item_id
      #   # puts version.item_type
      #   # puts version.event
      #   # puts version.object
      #   puts version.whodunnit
      #   # puts version.created_at
      #   puts "---"
      # end
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

    def default_sort_column
      'name asc'
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
