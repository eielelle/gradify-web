class Admin::AdminsController < Admin::LayoutController
    def index
        @admins = AdminAccount.all;

        puts @admins.first.attributes
        puts @admins.first.permissions.first.name
    end
end
