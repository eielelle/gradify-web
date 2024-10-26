class AddJtiToTeacherAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :teacher_accounts, :jti, :string
    add_index :teacher_accounts, :jti
  end
end
