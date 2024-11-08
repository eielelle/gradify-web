class CreateSchoolSectionsSubjectsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :school_sections, :subjects do |t|
      t.index :school_section_id
      t.index :subject_id
    end
  end
end
