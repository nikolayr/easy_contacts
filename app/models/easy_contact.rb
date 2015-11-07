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
                     :date_column => 'date_created',
                     :sort_order  => 'date_created',
                     :permission => :view_easy_contacts,
                     :include => {:project => :enabled_modules},
                     :project_key => "#{EasyContact.table_name}.project_id"

  # get easy_contacts linked to journal details records on Contact Created, Contact Updated

  # acts_as_activity_provider :type => 'easy_contacts',
  #                           :author_key => :author_id,
  #                           :permission => :view_easy_contacts,
  #                           :find_options => {:select => "#{EasyContact.table_name}.*",
  #                                             :joins => "LEFT JOIN #{Project.table_name} ON #{EasyContact.table_name}.project_id = #{Project.table_name}.id"},
  #                           :timestamp => "#{table_name}.date_created"

  acts_as_activity_provider :type => 'easy_contacts_update',
                            :author_key => :author_id,
                            :permission => :view_easy_contacts,
                            :timestamp => "#{table_name}.date_created",
                            :find_options => {:select => "#{EasyContact.table_name}.*,#{Journal.table_name}.notes,#{Journal.table_name}.created_on",
                                              :joins => "LEFT JOIN #{Project.table_name} ON #{EasyContact.table_name}.project_id = #{Project.table_name}.id " +
                                                        "LEFT JOIN #{Journal.table_name} ON #{EasyContact.table_name}.id = #{Journal.table_name}.journalized_id AND #{Journal.table_name}.journalized_type='EasyContact'"}

#  Proc.new {|o| {:controller => 'attachments', :action => 'download', :id => o.id, :filename => o.filename}}

  #has_one :journal, :foreign_key => :journalized_id, :as => :journalized
  #:dependent => :destroy

  acts_as_event :title => :get_activity_title,
                :url => :get_activity_url

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    @current_journal.notify = false
    @current_journal
  end

  # called after_save
  def save_journal_info(*args)
    unless @current_journal.nil?

      # if self.changed?
      #   @current_journal.details << JournalDetail.new(:property => 'easy_contact', :prop_key => self.id, :value => "contact record updated")
      # end

      @current_journal.save
      # reset current journal
      init_journal @current_journal.user, @current_journal.notes
    end
  end

  def generate_timestamp
    self.date_created = current_time_from_proper_timezone if self.date_created.nil?
  end

  def attachment_added(obj)
    if @current_journal && !obj.new_record?
      @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => obj.id, :value => obj.filename)
    end
  end

# Callback on attachment deletion
  def attachment_removed(obj)
    # TODO check attachment removement
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
    ec_user = self.author_id
    if self.has_attribute? :user_id && !self.attributes['user_id'].nil?
      ec_user = self.attributes['user_id']
    end

    ec_user == 0 ? l(:label_user_anonymous) : User.find(ec_user).name(:firstname_lastname)
  end

  def get_activity_title(*p)
    a_title = ''
    if self.has_attribute? :notes
        if !!/.*Created.*/i.match(self.attributes['notes'])
          a_title = l(:activity_ec_title_created,:id=>self.id)
        else
          if !!/.*Updated.*/i.match(self.attributes['notes'])
            a_title = l(:activity_ec_title_updated,:id=>self.id)
          end
        end
    end

    if a_title.empty?
      l(:activity_ec_title,:id=>self.id,:first_name=>self.first_name,:last_name=>self.last_name)
    else
      a_title
    end
  end

  def get_activity_url(*p)
    {controller: 'easy_contacts', action: 'show', id: self.id}
  end

  def created_on(*p)
    if self.has_attribute? :notes
      self.attributes['created_on'].nil? ? self.date_created+1 : Time.zone.parse(self.attributes['created_on'])
    else
      self.date_created
    end
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
