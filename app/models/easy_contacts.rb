class EasyContacts < ActiveRecord::Base
  unloadable
  before_save :generate_timestamp

  def generate_timestamp
    self.date_created = DateTime.now if self.date_created.nil?
  end

end
