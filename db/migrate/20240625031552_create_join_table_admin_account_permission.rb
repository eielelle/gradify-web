class CreateJoinTableAdminAccountPermission < ActiveRecord::Migration[7.1]
  def change
    create_join_table :admin_accounts, :permissions do |t|
      # t.index [:admin_account_id, :permission_id]
      # t.index [:permission_id, :admin_account_id]
    end
  end
end
