class ContactsCustomFields < CustomField
  unloadable
  def type_name
    :label_custom_contact
  end
end

class EasyContact < ActiveRecord::Base

#  attr_reader :first_name,:last_name,:date_created

  before_save :generate_timestamp

  acts_as_attachable :after_add => :attachment_added, :after_remove => :attachment_removed
  acts_as_customizable

=begin

  has_and_belongs_to_many :contacts_custom_fields,
                          :class_name => 'ContactsCustomFields',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_contacts#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
=end

  acts_as_customizable
  acts_as_searchable :columns => ['first_name', 'last_name'], :project_key => 'id', :permission => nil
  acts_as_event :title => Proc.new {|o| "#{l(:label_custom_contact)}: #{o.first_name}"},
                :url => Proc.new {|o| {:controller => 'easy_contacts', :action => 'show', :id => o}},
                :author => nil

  def generate_timestamp
    self.date_created = DateTime.now if self.date_created.nil?
  end

  def self.visible
    true
  end

  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end



end
