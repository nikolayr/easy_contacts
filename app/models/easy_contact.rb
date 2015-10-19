class ContactsCustomFields < CustomField
  unloadable
  def type_name
    :label_custom_contact
  end
end

class EasyContact < ActiveRecord::Base
  unloadable

  before_save :generate_timestamp
  after_save :create_journal

  #validators
  #validates_presence_of :first_name
  #validates_length_of :first_name, :maximum => 30


  acts_as_attachable :after_add => :attachment_added,
                     :after_remove => :attachment_removed

  #attr_accessor :custom_field_values, :custom_fields
  #safe_attributes 'custom_field_values', 'custom_fields'

=begin
  acts_as_customizable
  has_and_belongs_to_many :contacts_custom_fields,
                          :class_name => 'ContactsCustomFields',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_contacts#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
=end

  acts_as_searchable :columns => ['first_name', 'last_name', 'date_created'],
                     :project_key => 'project_id',
                     :date_column => 'date_created',
                     :sort_order  => 'date_created',
                     :permission => :view_easy_contacts
# 2do refine project id  :project_key => "#{Repository.table_name}.project_id",

  acts_as_activity_provider :type => 'easy_contact_created',
                            :author_key => nil,
#                            :find_options => {:include => [:first_name, :last_name]},
                            :find_options => {:select => "#{EasyContact.table_name}.*",
                                              :joins => "LEFT JOIN #{Project.table_name} ON #{EasyContact.table_name}.project_id = #{Project.table_name}.id"},
                            :timestamp => "#{table_name}.date_created"
# refine activity
#  https://www.redmine.org/boards/3/topics/32790

  acts_as_event :title => :filename,
                :url => Proc.new {|o| {:controller => 'easy_contacts',
                                       :action => 'show',
                                       :id => o.id}}
                                    #, :filename => o.filename}}


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

    custom_field_values = [] #2do reove this stub
    if @current_journal
      # attributes changes
      if @attributes_before_change
        (Issue.column_names - %w(id first_name last_name date_created)).each {|c|
          before = @attributes_before_change[c]
          after = send(c)
          next if before == after || (before.blank? && after.blank?)
          @current_journal.details << JournalDetail.new(:property => 'attr',
                                                        :prop_key => c,
                                                        :old_value => before,
                                                        :value => after)
        }
      end
      if @custom_values_before_change
        # custom fields changes
        custom_field_values.each {|c|
          before = @custom_values_before_change[c.custom_field_id]
          after = c.value
          next if before == after || (before.blank? && after.blank?)

          if before.is_a?(Array) || after.is_a?(Array)
            before = [before] unless before.is_a?(Array)
            after = [after] unless after.is_a?(Array)

            # values removed
            (before - after).reject(&:blank?).each do |value|
              @current_journal.details << JournalDetail.new(:property => 'cf',
                                                            :prop_key => c.custom_field_id,
                                                            :old_value => value,
                                                            :value => nil)
            end
            # values added
            (after - before).reject(&:blank?).each do |value|
              @current_journal.details << JournalDetail.new(:property => 'cf',
                                                            :prop_key => c.custom_field_id,
                                                            :old_value => nil,
                                                            :value => value)
            end
          else
            @current_journal.details << JournalDetail.new(:property => 'cf',
                                                          :prop_key => c.custom_field_id,
                                                          :old_value => before,
                                                          :value => after)
          end
        }
      end
      @current_journal.save
      # reset current journal
      init_journal @current_journal.user, @current_journal.notes
    end
  end

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    if new_record?
      @current_journal.notify = true # new issue is not notified? false
    else
      @attributes_before_change = attributes.dup
      @custom_values_before_change = {}
      #self.custom_field_values.each {|c| @custom_values_before_change.store c.custom_field_id, c.value }
    end
    @current_journal
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
=begin
    if @current_journal && !obj.new_record?
      @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => obj.id, :old_value => obj.filename)
      @current_journal.save
    end
=end
    puts "attachment_removed"

  end


  def project
    @attributes[:project_id]
  end

  def attachments_visible?(user)
    #User.current.allowed_to?
    #User.current.logged?
    User.current.allowed_to?(:view_easy_contacts_attachments, Project.find(self.project_id))
  end

  def attachments_deletable?(user = User.current)
    #User.current.logged?
    User.current.allowed_to?(:delete_easy_contacts_attachments, Project.find(self.project_id))
  end


  def find_events(event_type, user, from, to, options)
    puts "meow"
  end

  def visible?(user, *options)
    # 2do add access check for activity
    true
  end

  def created_on(*p)
    self.date_created.to_date
  end
end
