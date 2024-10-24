class AddNameToStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :student_accounts, :name, :string
  end
end
