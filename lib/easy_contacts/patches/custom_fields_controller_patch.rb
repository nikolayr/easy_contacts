module EasyContacts
  module Patches
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :index, :custom_client_field
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def index_with_custom_client_field
          CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'EasyContactsCustomField',
                                                     :partial => 'custom_fields/index',
                                                     :label => :label_easy_contacts_plural} unless @contact_custom_field_added
          @contact_custom_field_added = true

=begin
TODO do not grow CUSTOM_FIELDS_TABS array
          ccf = CustomFieldsHelper::CUSTOM_FIELDS_TABS.select {|h| h[:name] == 'ContactsCustomField'}
          if ccf.nil?
          end
=end

        end
      end #InstanceMethods
    end #CustomFieldsControllerPatch
  end
end

