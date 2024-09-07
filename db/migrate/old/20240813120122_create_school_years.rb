class CreateSchoolYears < ActiveRecord::Migration[7.1]
  def change
    create_table :school_years do |t|
      t.references :school_class, null: false, foreign_key: true
      t.date :start
      t.date :end
      t.string :name

      t.timestamps
    end
  end
end
