Redmine::Plugin.register :easy_contacts do
  name 'Easy Contacts plugin'
  author 'Nikolai Ruban'
  description 'Plugins allows creation of Contacts records within project.'
  version '0.0.1'
  url 'https://github.com:nikolayr/easy_contacts.git'
  author_url 'https://github.com/nikolayr'
  requires_redmine :version_or_higher => '2.6.0'

  project_module :easy_contacts do
    permission :view_easy_contacts, :easy_contacts => :index
    permission :view_easy_contacts_attachments, :attachments => :index
    permission :delete_easy_contacts_attachments, :attachments => :destroy
  end

  Redmine::Activity.map do |activity|
    activity.register(:easy_contact_created,{:class_name => 'EasyContact'})
  end

  menu :project_menu, :easy_contacts , { :controller => 'easy_contacts', :action => 'index'},
       :caption => (:easy_contacts_proj_menu_str) , :param => :project_id, :after => :settings

end

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'custom_fields_controller'
  unless CustomFieldsController.included_modules.include?(EasyContacts::Patches::CustomFieldsControllerPatch)
    CustomFieldsController.send(:include, EasyContacts::Patches::CustomFieldsControllerPatch)
  end
end

Redmine::Search.map do |search|
  search.register :easy_contacts
end
