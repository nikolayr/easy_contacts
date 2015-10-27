class EasyContactCustomField < CustomField

  def type_name
    :label_easy_contact_plural
  end

  def visible_by?(project, user=User.current)
    true
  end

  def visibility_by_project_condition(project_key=nil, user=User.current, id_column=nil)
    true
  end

  def validate_custom_field(*args)
    super
    errors.add(:base, l(:label_role_plural) + ' ' + l('activerecord.errors.messages.blank')) unless visible?
  end

   # def custom_field(*args)
   #   self
   # end

  # def value(*args)
  #   #[#<CustomValue id: 12, customized_type: "EasyContact", customized_id: 11, custom_field_id: 9, value: "">,
  #   # #<CustomValue id: 13, customized_type: "EasyContact", customized_id: 12, custom_field_id: 9, value: "yolo">]
  #   #self.custom_values.last which one???
  #   self.default_value
  #   #self.custom_values ???
  # end

end
