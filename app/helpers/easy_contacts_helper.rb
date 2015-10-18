module EasyContactsHelper
    include ApplicationHelper

    def contacts_heading(item)
      h("#{l(:easy_contact_snglr)} ##{item.id}")
    end

    def econ_id(item)
      "#{item.id}"
    end

    def econ_path(item)
      "easy_contacts/#{item.id}"
    end

end
