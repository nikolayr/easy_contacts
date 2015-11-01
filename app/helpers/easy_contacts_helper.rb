module EasyContactsHelper
    include ApplicationHelper

    # def contacts_list(ec, &block)
    #   ancestors = []
    #   ec.each do |contact|
    #     while (ancestors.any? && !issue.is_descendant_of?(ancestors.last))
    #       ancestors.pop
    #     end
    #     yield contact, ancestors.size
    #     ancestors << contact unless contact.leaf?
    #   end
    # end

    def contacts_heading(item)
      h("#{l(:easy_contact_snglr)} ##{item.id}")
    end

    def econ_id(item)
      "#{item.id}"
    end

    def easy_contact_path(o,*p)
      {controller: 'easy_contacts', action: 'show', id: o.id}
    end

    def contact_column_content(column, issue)
      value = column.value_object(issue)
      if value.is_a?(Array)
        value.collect {|v| contact_column_value(column, issue, v)}.compact.join(', ').html_safe
      else
        contact_column_value(column, issue, value)
      end
    end

    def contact_column_value(column, issue, value)
      puts "column_value"
      case column.name
        when :id
          link_to value, easy_contact_path(issue)
        when :subject
          link_to value, easy_contact_path(issue)
        when :description
          issue.description? ? content_tag('div', textilizable(issue, :description), :class => "wiki") : ''
        when :done_ratio
          progress_bar(value, :width => '80px')
        else
          format_object(value)
      end
    end

end
