class EasyContactsCustomField < CustomField
#  has_and_belongs_to_many :easy_contacts, :join_table => "#{table_name_prefix}custom_fields_contacts#{table_name_suffix}", :foreign_key => "custom_field_id"
  has_many :easy_contacts, :through => :contacts_custom_values

  def type_name
    :label_easy_contacts_plural
  end

  def visible_by?(project, user=User.current)
    true
    #super || (roles & user.roles_for_project(project)).present?
  end

  def visibility_by_project_condition(project_key=nil, user=User.current, id_column=nil)
    true
    # sql = super
    # id_column ||= id
    #
    # project_condition = "EXISTS (SELECT 1 FROM #{CustomField.table_name} ifa WHERE ifa.is_for_all = #{connection.quoted_true} AND ifa.id = #{id_column})" +
    #     " OR #{Issue.table_name}.project_id IN (SELECT project_id FROM #{table_name_prefix}custom_fields_projects#{table_name_suffix} WHERE custom_field_id = #{id_column})"
    #
    # "((#{sql}) AND (#{project_condition}))"
  end

  def validate_custom_field
    super
    errors.add(:base, l(:label_role_plural) + ' ' + l('activerecord.errors.messages.blank')) unless visible?
  end

end
