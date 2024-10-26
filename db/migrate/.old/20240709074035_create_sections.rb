class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.boolean :archived

      t.timestamps
    end
  end
end
