class AddDeviseTrackableToStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :student_accounts, :sign_in_count, :integer, default: 0, null: false
    add_column :student_accounts, :current_sign_in_at, :datetime
    add_column :student_accounts, :last_sign_in_at, :datetime
    add_column :student_accounts, :current_sign_in_ip, :inet
    add_column :student_accounts, :last_sign_in_ip, :inet
  end
end
