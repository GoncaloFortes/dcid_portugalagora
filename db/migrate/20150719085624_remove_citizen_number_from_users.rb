class RemoveCitizenNumberFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :citizen_number
  end

  def down
    add_column :users, :citizen_number, :string
    add_index :users, :citizen_number, unique: true
  end
end
