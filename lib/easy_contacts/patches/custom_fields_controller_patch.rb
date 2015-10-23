module EasyContacts
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :initialize, :add_custom_contact_tab
          alias_method_chain :custom_field_type_options, :custom_client_field
        end
      end

      module ClassMethods
      end #ClassMethods

      module InstanceMethods

        def initialize_with_add_custom_contact_tab(*args)
          puts "pre init CustomFieldsHelper::CUSTOM_FIELDS_TABS.size:#{CustomFieldsHelper::CUSTOM_FIELDS_TABS.size}"
          easy_contact_field_tab
        end

        def redef_without_warning(const, value)
          self.class.send(:remove_const, const) if self.class.const_defined?(const)
          self.class.const_set(const, value)
        end

        def easy_contact_field_tab
          @@ec_tab_added ||= false
          unless @@ec_tab_added
            custom_fields = CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'EasyContactsCustomField',
                                                                       :partial => 'custom_fields/index',
                                                                       :label => :label_easy_contacts_plural}
            redef_without_warning 'CUSTOM_FIELDS_TABS', custom_fields
            @@ec_tab_added = true
          end
        end

        def custom_field_type_options_with_custom_client_field
          puts "CustomFieldsHelper::CUSTOM_FIELDS_TABS.size:#{CustomFieldsHelper::CUSTOM_FIELDS_TABS.size}"
        end

      end #InstanceMethods
    end #CustomFieldsControllerPatch
  end
end

