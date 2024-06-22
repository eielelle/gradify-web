class AdminPermission < ApplicationRecord
  belongs_to :admin_account
  belongs_to :permission
end
