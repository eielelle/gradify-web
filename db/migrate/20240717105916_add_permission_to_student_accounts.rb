class AddPermissionToStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    # Step 2.1: Add the column without NOT NULL constraint
    add_reference :student_accounts, :permission, foreign_key: true

    # Step 2.2: Set default permission for existing records
    reversible do |dir|
      dir.up do
        default_permission_id = Permission.find_by(name: 'Default').id
        StudentAccount.update_all(permission_id: default_permission_id)
      end
    end

    # Step 2.3: Change the column to NOT NULL
    change_column_null :student_accounts, :permission_id, false
  end
end