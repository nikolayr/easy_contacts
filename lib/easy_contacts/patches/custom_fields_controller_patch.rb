module EasyContacts
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
#          alias_method_chain :render_custom_fields_tabs, :add_custom_client_field
#          alias_method_chain :custom_field_type_options, :custom_client_field
        end
      end

      module ClassMethods
      end

      module InstanceMethods

        # def initialize(*args)
        #   puts "pops"
        #   easy_contact_field_tab
        # end

        def easy_contact_field_tab
          @@ec_tab_added ||= false
          unless @@ec_tab_added
            # CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'EasyContactsCustomField',
            #                                            :partial => 'custom_fields/index',
            #                                            :label => :label_easy_contacts_plural}
            @@ec_tab_added = true
          end
        end

        def render_custom_fields_tabs_with_add_custom_client_field(*args)
          easy_contact_field_tab
          tabs = CUSTOM_FIELDS_TABS.select {|h| types.include?(h[:name]) }
          render_tabs tabs

        end

        def custom_field_type_options_with_custom_client_field(*args)
          easy_contact_field_tab
        end

      end #InstanceMethods
    end #CustomFieldsControllerPatch
  end
end

