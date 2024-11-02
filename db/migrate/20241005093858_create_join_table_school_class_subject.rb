class CreateJoinTableSchoolClassSubject < ActiveRecord::Migration[7.1]
  def change
    create_join_table :school_classes, :subjects do |t|
      t.index :school_class_id  # Add an index for faster lookups
      t.index :subject_id       # Add an index for faster lookups
    end
  end
end
