class CreatePermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.text :description, null: false, default: ""

      t.timestamps
    end
  end
end
