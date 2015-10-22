class CreateEasyContactsField < ActiveRecord::Migration

  def self.up
    add_column :easy_contacts, :easy_contact_id, :integer, default: 0
  end

  def self.down
    remove_column :easy_contacts, :easy_contact_id
  end

end
