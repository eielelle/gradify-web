class CreateExams < ActiveRecord::Migration[7.1]
  def change
    create_table :exams do |t|
      t.string :name
      t.references :subject, null: false, foreign_key: true
      t.integer :items
      t.string :answer_key

      t.timestamps
    end
  end
end
