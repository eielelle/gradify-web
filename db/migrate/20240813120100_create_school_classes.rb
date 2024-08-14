class CreateSchoolClasses < ActiveRecord::Migration[7.1]
  def change
    create_table :school_classes do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
