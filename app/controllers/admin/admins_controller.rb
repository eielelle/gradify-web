# frozen_string_literal: true

module Admin
  class AdminsController < Admin::LayoutController
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
