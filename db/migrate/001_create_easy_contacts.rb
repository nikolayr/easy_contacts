class CreateEasyContacts < ActiveRecord::Migration
/*
  def self.up
    add_column :easy_contacts, :first_name, :string, :null => true
    add_column :easy_contacts, :last_name, :string, :null => true
    add_column :easy_contacts, :date_created, :timestamp, :null => true
  end

  def self.down
    remove_column :easy_contacts, :first_name
    remove_column :easy_contacts, :last_name 
    remove_column :easy_contacts, :date_created
  end
*/

  def change
    create_table :easy_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.timestamp :date_created
    end
  end
end
