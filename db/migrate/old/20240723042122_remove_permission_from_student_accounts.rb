class RemovePermissionFromStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    remove_reference :student_accounts, :permission, null: false, foreign_key: true
  end
end
