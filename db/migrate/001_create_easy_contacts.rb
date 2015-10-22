class CreateEasyContacts < ActiveRecord::Migration

  def self.up
    create_table :easy_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.timestamp :date_created
    end
  end

  def self.down
    drop_table :easy_contacts
  end

end
