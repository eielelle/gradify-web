class Admin::AdminsController < Admin::LayoutController
    def index
        @admins = AdminAccount.select(:id, :name, :email).page(params[:page]).per(10)
        @count = AdminAccount.count

        puts @admins.first.attributes
        # puts @admins.first.permissions.first.name
    end
end
