class CreateAdminPermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_permissions do |t|
      t.references :admin_account, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.timestamps
    end
  end
end
