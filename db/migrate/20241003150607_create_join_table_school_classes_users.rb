class CreateJoinTableSchoolClassesUsers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :school_classes, :users do |t|
      t.index :school_class_id
      t.index :user_id
    end
  end
end
