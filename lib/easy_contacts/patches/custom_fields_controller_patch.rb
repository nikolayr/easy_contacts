module EasyContacts
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc:
        @bbb ||= base
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :index, :add_custom_contact_tab
#          alias_method_chain :custom_field_type_options, :custom_client_field
        end
      end

      module ClassMethods
      end #ClassMethods

      module InstanceMethods

        def index_with_add_custom_contact_tab(*args)
          easy_contact_field_tab
        end

        #redef const in module
        def redef_without_warning(const, value)
          @bbb.class.send(:remove_const, const) if @bbb.class.const_defined?(const)
          @bbb.class.const_set(const, value)
        end

        def easy_contact_field_tab(*args)
          @@ec_tab_added ||= false
          unless @@ec_tab_added
            custom_fields = CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'EasyContactsCustomField',
                                                                       :partial => 'custom_fields/index',
                                                                       :label => :label_easy_contacts_plural}
            redef_without_warning 'CUSTOM_FIELDS_TABS', custom_fields
            @@ec_tab_added = true
          end
        end

      end #InstanceMethods
    end #CustomFieldsControllerPatch
  end
end

