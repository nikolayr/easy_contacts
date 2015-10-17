module EasyContactsHelper
    include ApplicationHelper

    def contacts_heading(item)
      h("#{l(:easy_contact_snglr)} ##{item.id}")
    end

end
