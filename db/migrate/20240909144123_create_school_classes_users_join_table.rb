class CreateSchoolClassesUsersJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :users, :school_sections do |t|
      t.index :user_id
      t.index :school_section_id
      t.integer :subject_id, index: true
    end

    # create_join_table :school_sections, :users do |t|
    #   t.index :school_class_id
    #   t.index :user_id
    # end

    # create_join_table :school_classes, :users do |t|
    #   t.index :school_class_id
    #   t.index :user_id
    # end
  end
end
