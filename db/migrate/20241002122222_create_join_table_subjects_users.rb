class CreateJoinTableSubjectsUsers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :subjects, :users do |t|
      # t.index [:subject_id, :user_id]
      # t.index [:user_id, :subject_id]
    end
  end
end
