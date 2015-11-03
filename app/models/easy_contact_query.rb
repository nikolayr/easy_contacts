  class EasyContactQuery < Query

    self.queried_class = EasyContact

    self.available_columns = [
        QueryColumn.new(:id, :sortable => "#{EasyContact.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => true),
        QueryColumn.new(:first_name, :sortable => "#{EasyContact.table_name}.first_name"),
        QueryColumn.new(:last_name, :sortable => "#{EasyContact.table_name}.last_name"),
        QueryColumn.new(:date_created, :sortable => "#{EasyContact.table_name}.date_created"),
        QueryColumn.new(:author_id, :sortable => "#{EasyContact.table_name}.author_id"),
        QueryColumn.new(:project_id, :sortable => "#{EasyContact.table_name}.project_id")
    ]

    scope :visible, -> { where(visible: true) }

    def initialize(attributes=nil, *args)
      super attributes
      self.filters ||= { 'project_id' => {:operator => "o", :values => [""]} }
    end

    # Returns true if the query is visible to +user+ or the current user.
    def visible?(user=User.current)
      true
    end

    def is_private?
      false
    end

    def is_public?
      true
    end

    def draw_relations
      true
    end

    def draw_relations=(arg)
      options[:draw_relations] = (arg == '0' ? '0' : nil)
    end

    def draw_progress_line
      r = options[:draw_progress_line]
      r == '1'
    end

    def draw_progress_line=(arg)
      options[:draw_progress_line] = (arg == '1' ? '1' : nil)
    end

    def build_from_params(params)
      super
      self.draw_relations = params[:draw_relations] || (params[:query] && params[:query][:draw_relations])
      self.draw_progress_line = params[:draw_progress_line] || (params[:query] && params[:query][:draw_progress_line])
      self
    end

    def initialize_available_filters

      add_available_filter "first_name", :type => :text
      add_available_filter "last_name", :type => :text
      add_available_filter "date_created", :type => :date

     custom_fields = EasyContactCustomField.where(is_for_all: false)
     add_custom_fields_filters(custom_fields)

     #add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version

    end

    def available_columns
      return @available_columns if @available_columns
      @available_columns = self.class.available_columns.dup
      @available_columns
    end

    def default_columns_names
      @default_columns_names ||= begin
        default_columns = Setting.issue_list_default_columns.map(&:to_sym)

        project.present? ? default_columns : [:project] | default_columns
      end
    end

    def contacts_count
      EasyContact.where( statement ).count
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    # Returns the issues
    # Valid options are :order, :offset, :limit, :include, :conditions
    def contacts(options={})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

      scope = EasyContact.
          where(statement).
          where(options[:conditions]).
          order(order_option).
          joins(joins_for_order_statement(order_option.join(','))).
          limit(options[:limit]).
          offset(options[:offset])

      scope = scope.preload(:custom_values)
      if has_column?(:author)
        scope = scope.preload(:author)
      end

      scope.all
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    # Returns the issues ids
    def contacts_ids(options={})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

      EasyContact.visible.
          where(statement).
          where(options[:conditions]).
          order(order_option).
          joins(joins_for_order_statement(order_option.join(','))).
          limit(options[:limit]).
          offset(options[:offset]).
          find_ids
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    # IssueRelation::TYPES.keys.each do |relation_type|
    #   alias_method "sql_for_#{relation_type}_field".to_sym, :sql_for_relations
    # end

    def project_statement
      "project_id in (#{project.id})"
    end

   def statement
     # TODO return query statements to filter contacts
     ''
   end


end
