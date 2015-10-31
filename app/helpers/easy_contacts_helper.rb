module EasyContactsHelper
    include ApplicationHelper

    def contacts_list(issues, &block)
      ancestors = []
      issues.each do |issue|
        while (ancestors.any? && !issue.is_descendant_of?(ancestors.last))
          ancestors.pop
        end
        yield issue, ancestors.size
        ancestors << issue unless issue.leaf?
      end
    end

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
