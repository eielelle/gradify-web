class CreateQuarters < ActiveRecord::Migration[7.1]
  def change
    create_table :quarters do |t|
      t.string :name

      t.timestamps
    end
  end
end
