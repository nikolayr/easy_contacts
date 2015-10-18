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
    permission :create_easy_contacts, :easy_contacts => :new
  end

  settings :default => { :easy_contacts_enabled => true}
#  ,:partial => 'settings/easy_contacts_settings'

  menu :project_menu, :easy_contacts , { :controller => 'easy_contacts', :action => 'index'}, :caption => (:easy_contacts_proj_menu_str) , :param => :project_id, :after => :settings

end
