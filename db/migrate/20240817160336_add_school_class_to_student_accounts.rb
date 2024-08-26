class AddSchoolClassToStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :student_accounts, :school_class, null: false, foreign_key: true
  end
end
