class AddReferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    # add_reference :users, :school_year, null: true, foreign_key: true
    # add_reference :users, :school_section, null: true, foreign_key: true
    # add_reference :school_classes, :school_section, null: true, foreign_key: true

    # add_reference :school_years, :school_class, null: true, foreign_key: true
    # add_reference :school_sections, :school_year, null: true, foreign_key: true
    add_reference :users, :school_section, null: true, foreign_key: true
  end
end
