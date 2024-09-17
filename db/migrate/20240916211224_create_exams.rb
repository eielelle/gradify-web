class CreateExams < ActiveRecord::Migration[7.1]
  def change
    create_table :exams do |t|
      t.string :name
      t.string :subject
      t.integer :items
      t.string :answer_key

      t.timestamps
    end
  end
end
