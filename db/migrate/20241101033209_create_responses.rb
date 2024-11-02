class CreateResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :responses do |t|
      t.references :exam, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :student_number
      t.string :image_path
      t.integer :detected
      t.integer :score
      t.string :answer

      t.timestamps
    end
  end
end
