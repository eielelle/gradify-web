class CreateQuarters < ActiveRecord::Migration[7.1]
  def change
    create_table :quarters do |t|
      t.references :school_year, null: false, foreign_key: true
      t.date :start
      t.date :end
      t.string :name

      t.timestamps
    end
  end
end
