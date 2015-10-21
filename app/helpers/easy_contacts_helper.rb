module EasyContactsHelper
    include ApplicationHelper

    def contacts_heading(item)
      h("#{l(:easy_contact_snglr)} ##{item.id}")
    end

    def econ_id(item)
      "#{item.id}"
    end

    def easy_contact_path(o,*p)
      {controller: 'easy_contacts', action: 'show', id: o.id}
    end
end
