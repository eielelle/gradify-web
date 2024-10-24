class AddSchoolClassIdToSubjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :subjects, :school_class, null: false, foreign_key: true
  end
end
