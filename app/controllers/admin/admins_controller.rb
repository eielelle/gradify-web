class Admin::AdminsController < Admin::LayoutController
    def index
        @admins = AdminAccount.all;
        @active_tab = :index;
    end
end
