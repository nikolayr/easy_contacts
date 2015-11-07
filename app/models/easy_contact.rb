class EasyContact < ActiveRecord::Base
  include Redmine::SafeAttributes

  before_save :generate_timestamp

  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 30
  validates_length_of :last_name, :maximum => 30

  after_save :save_journal_info

  safe_attributes 'first_name', 'last_name'
  acts_as_attachable :after_add => :attachment_added,
                     :after_remove => :attachment_removed

  attr_accessor :custom_fields

  acts_as_customizable
  has_and_belongs_to_many :easy_contact_custom_field,
                          :class_name => 'EasyContactCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_contacts#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'


  belongs_to :project

  acts_as_searchable :columns => ['first_name', 'last_name'],
                     :project_key => 'project_id',
                     :date_column => 'date_created',
                     :sort_order  => 'date_created',
                     :permission => :view_easy_contacts,
                     :include => {:project => :enabled_modules},
                     :project_key => "#{EasyContact.table_name}.project_id"

# TODO refine project id  :project_key => "#{EasyContact.table_name}.project_id",

  acts_as_activity_provider :type => 'easy_contacts',
                            :author_key => :author_id,
                            :permission => :view_easy_contacts,
#                            :find_options => {:include => [:first_name, :last_name]},
                            :find_options => {:select => "#{EasyContact.table_name}.*",
                                              :joins => "LEFT JOIN #{Project.table_name} ON #{EasyContact.table_name}.project_id = #{Project.table_name}.id"},
                            :timestamp => "#{table_name}.date_created"
# refine activity
#  https://www.redmine.org/boards/3/topics/32790

  acts_as_event :title => :get_activity_title,
                :url => :get_activity_url

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    @current_journal.notify = false

    if new_record?
      @current_journal.notify = false
    else
      #save fields values for further storing in journal in case of values change
      # @attributes_before_change = attributes.dup
      # @custom_values_before_change = {}
      # self.custom_field_values.each {|c| @custom_values_before_change.store c.custom_field_id, c.value }
    end
    @current_journal
  end

  # called after_save
  def save_journal_info(*args)
    puts "@current_journal must be stored"
    #      @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => obj.id, :value => obj.filename)

    unless @current_journal.nil?

      if self.changed?
        @current_journal.details << JournalDetail.new(:property => 'easy_contact', :prop_key => self.id, :value => "contact record updated")
      end

      @current_journal.save
      # reset current journal
      init_journal @current_journal.user, @current_journal.notes
    end
  end

  def generate_timestamp
    self.date_created = DateTime.now if self.date_created.nil?
  end

  def attachment_added(obj)
    if @current_journal && !obj.new_record?
      @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => obj.id, :value => obj.filename)
    end
  end

# Callback on attachment deletion
  def attachment_removed(obj)
    # TODO find attachment adn remove it (unless it's not required in another record)
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

  def init_custom_flds
    @custom_fields = EasyContactCustomField.where("type='EasyContactCustomField'").sorted.all
    @custom_field_values ||= self.custom_field_values
  end

  # Overrides Redmine::Acts::Customizable::InstanceMethods#available_custom_fields
  def available_custom_fields
    @custom_fields ||= EasyContactCustomField.where("type = 'EasyContactCustomField'").sorted.all
    @custom_fields
  end

end
