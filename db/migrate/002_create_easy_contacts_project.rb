class CreateEasyContactsProject < ActiveRecord::Migration

  def self.up
    add_column :easy_contacts, :project_id, :integer, default: 0
  end

  def self.down
    remove_column :easy_contacts, :project_id
  end

end
