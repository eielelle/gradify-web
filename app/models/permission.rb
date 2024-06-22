class Permission < ApplicationRecord
    has_many :admin_permissions
    has_many :admin_accounts, through: :admin_permissions
end
