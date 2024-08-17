class CreateSchoolSections < ActiveRecord::Migration[7.1]
  def change
    create_table :school_sections do |t|
      t.references :school_class, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
