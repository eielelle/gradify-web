# frozen_string_literal: true

module Admin
  class AdminsController < Admin::LayoutController
    def index
      @admins = AdminAccount.select(:id, :name, :email).page(params[:page]).per(10)
      @count = AdminAccount.count

      Rails.logger.debug @admins.first.attributes
      # puts @admins.first.permissions.first.name
    end
  end
end
