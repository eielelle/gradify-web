class AddSubjectIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :subject_id, :integer
  end
end
