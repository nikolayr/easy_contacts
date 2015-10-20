class CreateEasyContactsAuthorId < ActiveRecord::Migration

  def self.up
    add_column :easy_contacts, :author_id, :integer, default: 0
  end

  def self.down
    remove_column :easy_contacts, :author_id
  end

end
