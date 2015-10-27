class EasyContact < ActiveRecord::Base
  include Redmine::SafeAttributes

  before_create :init_custom_flds
  before_save :generate_timestamp

  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 30
  validates_length_of :last_name, :maximum => 30


  safe_attributes 'first_name', 'last_name'
  acts_as_attachable :after_add => :attachment_added,
                     :after_remove => :attachment_removed

  attr_accessor :custom_fields
#  attr_accessor :custom_field_values, :custom_fields
#  safe_attributes 'custom_field_values', 'custom_fields'

  acts_as_customizable
  #:easy_contacts_custom_field :easy_contacts
  has_and_belongs_to_many :easy_contact_custom_field,
                          :class_name => 'EasyContactCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_contacts#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'


# 2do review search functionality
  acts_as_searchable :columns => ['first_name', 'last_name', 'date_created'],
                     :project_key => 'project_id',
                     :date_column => 'date_created',
                     :sort_order  => 'date_created',
                     :permission => :view_easy_contacts
# 2do refine project id  :project_key => "#{Repository.table_name}.project_id",

  acts_as_activity_provider :type => 'easy_contact_created',
                            :author_key => nil,
                            :permission => :view_easy_contacts,
#                            :find_options => {:include => [:first_name, :last_name]},
                            :find_options => {:select => "#{EasyContact.table_name}.*",
                                              :joins => "LEFT JOIN #{Project.table_name} ON #{EasyContact.table_name}.project_id = #{Project.table_name}.id"},
                            :timestamp => "#{table_name}.date_created"
# refine activity
#  https://www.redmine.org/boards/3/topics/32790

  acts_as_event :title => :get_activity_title,
                :url => :get_activity_url



=begin
  acts_as_activity_provider :type => 'easy_contact_created',
                            :permission => :view_documents,
                            :author_key => :author_id,
                            :find_options => {:select => "#{EasyContact.table_name}.*",
                                              :joins => "LEFT JOIN #{Document.table_name} ON #{Attachment.table_name}.container_type='Document' AND #{Document.table_name}.id = #{Attachment.table_name}.container_id " +
                                                  "LEFT JOIN #{Project.table_name} ON #{Document.table_name}.project_id = #{Project.table_name}.id"}

=end

# Saves the changes in a Journal
# Called after_save
  def create_journal
    puts "no journa for now"
  end

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    if new_record?
      @current_journal.notify = false
    else
      @attributes_before_change = attributes.dup
      @custom_values_before_change = {}
      self.custom_field_values.each {|c| @custom_values_before_change.store c.custom_field_id, c.value }
    end
    @current_journal
  end

  def generate_timestamp
    self.date_created = DateTime.now if self.date_created.nil?
  end

  def attachment_added(obj)
    if @current_journal # && !obj.new_record?
      @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => obj.id, :value => obj.filename)
    end
  end

# Callback on attachment deletion
  def attachment_removed(obj)
    #puts "attachment_removed"
  end

  def project
    @attributes[:project_id]
  end

  def attachments_visible?(user)
    #User.current.logged?
    User.current.allowed_to?(:view_easy_contacts_attachments, Project.find(self.project_id))
  end

  def attachments_deletable?(user = User.current)
    #User.current.logged?
    User.current.allowed_to?(:delete_easy_contacts_attachments, Project.find(self.project_id))
  end

  def visible?(user, *options)
    # 2do add access check for activity
    true
  end

  def author(*p)
    if self.author_id == 0
      l(:label_user_anonymous)
    else
      User.find(self.author_id).name(:firstname_lastname)
    end
  end

  def get_activity_title(*p)
    l(:activity_ec_title,:id=>self.id,:first_name=>self.first_name,:last_name=>self.last_name)
  end

  def get_activity_url(*p)
    {controller: 'easy_contacts', action: 'show', id: self.id}
  end

  def created_on(*p)
    self.date_created
  end

  def description(*p)
    l(:activity_easy_contact_description)
  end

  # Safely sets attributes
  # Should be called from controllers instead of #attributes=
  # attr_accessible is too rough because we still want things like
  # Issue.new(:project => foo) to work
  # def safe_attributes=(attrs, user=User.current)
  #   return unless attrs.is_a?(Hash)
  #   attrs = attrs.dup
  #
  #   if attrs['custom_field_values'].present?
  #     editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
  #     # TODO: use #select when ruby1.8 support is dropped
  #     attrs['custom_field_values'] = attrs['custom_field_values'].reject {|k, v| !editable_custom_field_ids.include?(k.to_s)}
  #   end
  #
  #   if attrs['custom_fields'].present?
  #     editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
  #     # TODO: use #select when ruby1.8 support is dropped
  #     attrs['custom_fields'] = attrs['custom_fields'].reject {|c| !editable_custom_field_ids.include?(c['id'].to_s)}
  #   end
  #
  #   # mass-assignment security bypass
  #   assign_attributes attrs, :without_protection => true
  #
  # end

  def validate_value(*args)
    # TODO add validation check
    puts "validate values here"
    true
  end

  def init_custom_flds(*args)
    puts "initing custom_flds for EasyContactCustomField"
    @custom_fields = EasyContactCustomField.where("type='EasyContactCustomField'").sorted.all

    @custom_field_values ||= self.custom_field_values

    puts "init_custom_flds complete for #{self.id}"
  end

  def validate_custom_field_values
    unless @custom_field_values.nil?
      super
    else
      @custom_field_values ||= []
      puts "custom validate"
      #TODO validate custom fields, and push them to array custom_field_values
      #??? @custom_field_values.map(&:validate_value)
    end
  end

  # Overrides Redmine::Acts::Customizable::InstanceMethods#available_custom_fields
  def available_custom_fields
    puts "getting available_custom_fields"
    @custom_fields ||= EasyContactCustomField.where("type = 'EasyContactCustomField'").sorted.all
    @custom_fields
  end

  # def custom_fields(*args)
  #   puts "custom_fields"
  #   @custom_fields = EasyContactCustomField.where("type = 'EasyContactCustomField'").sorted.all
  #   @custom_fields
  # end

end
