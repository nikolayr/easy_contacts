class CreateEasyContacts < ActiveRecord::Migration

  def self.up
    create_table :easy_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.timestamp :date_created
    end

    create_table "custom_fields_contacts", :id => false, :force => true do |t|
      t.column "custom_field_id", :integer, :default => 0, :null => false
      t.column "easy_contact_id", :integer, :default => 0, :null => false
    end

  end

  def self.down
    drop_table :easy_contacts
    drop_table "custom_fields_contacts"
  end

end
