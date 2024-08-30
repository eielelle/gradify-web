class AddReferencesToStudentAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :student_accounts, :school_year, null: true, foreign_key: true
    add_reference :student_accounts, :school_section, null: true, foreign_key: true
  end
end
