module EasyContacts
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc:
#        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :render_custom_fields_tabs, :add_custom_client_field
          alias_method_chain :custom_field_type_options, :custom_client_field
        end
      end

#      module ClassMethods
#      end

      module InstanceMethods

        def my_custom_fields_tabs
          CustomFieldsHelper::CUSTOM_FIELDS_TABS
        end

        def easy_contact_field_tab
          ec_tab_added = my_custom_fields_tabs.select {|i| i[:name] == 'EasyContactsCustomField'}
          if ec_tab_added.empty?
            custom_fields_tabs ||= {:name => 'EasyContactsCustomField',
                                                       :partial => 'custom_fields/index',
                                                       :label => :label_easy_contacts_plural}
          end
        end

        def render_custom_fields_tabs_with_add_custom_client_field
          easy_contact_field_tab
        end

        def custom_field_type_options_with_custom_client_field
          easy_contact_field_tab
        end

      end #InstanceMethods
    end #CustomFieldsControllerPatch
  end
end

