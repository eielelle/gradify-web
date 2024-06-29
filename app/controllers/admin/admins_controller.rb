# frozen_string_literal: true

module Admin
  class AdminsController < Admin::LayoutController
    require 'csv'

    def index
      @admins = AdminAccount.select(:id, :name, :email).page(params[:page]).per(10)
      @count = AdminAccount.count
    end

    def new
      @permissions = Permission.all
    end

    def create
      permission = Permission.find(admin_params[:permission])

      return if permission.nil?

      admin = build_admin(permission)

      if admin.save
        redirect_to admin_admins_path
      else
        handle_errors(admin)
        redirect_to new_admin_admin_path
      end
    end

    def export
      @admin_fields = AdminAccount.get_export_fields([:encrypted_password, :reset_password_token])
      @permission_fields = Permission.get_export_fields
    end

    def send_exports
      @admins = AdminAccount.includes(:permissions);
      admins = params[:selected_admins].to_a || []
      permissions = params[:selected_permissions].to_a || []
      date = Date.today.strftime("%Y-%m-%d")

      if (params[:csv].present?)
        send_data AdminAccount.to_csv({admins: admins, permissions: permissions}), filename: "#{date}.csv"
      elsif (params[:json].present?)
        send_data AdminAccount.to_json({admins: admins, permissions: permissions}), filename: "#{date}.json"
      elsif (params[:xml].present?)
        send_data AdminAccount.to_xml({admins: admins, permissions: permissions}), filename: "#{date}.xml"
      end
    end

    private

    def handle_errors(model)
      model.errors.each do |error|
        flash[error.attribute] = "#{error.attribute.capitalize} #{model.errors[error.attribute].first}"
      end
    end

    def build_admin(permission)
      admin = AdminAccount.new admin_params.except(:permission)
      admin.permissions << permission

      admin
    end

    def admin_params
      params.permit(:name, :email, :permission, :password)
    end
  end
end
