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
      permission = Permission.find(100)

      if !permission.nil?
        admin = AdminAccount.new admin_params.except(:permission)
        admin.permission << permission

        if admin.save
          redirect_to admin_admins_path
        else
          admin.errors.each do |error|
            flash[error.attribute] = "#{error.attribute.capitalize} #{admin.errors[error.attribute].first}"
          end

          redirect_to new_admin_admin_path
        end
      end
    end

    private
    def admin_params
      params.permit(:name, :email, :permission, :password)
    end
  end
end
