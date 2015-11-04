module EasyContactsQueryHelper

  def ec_default_fields
    [:first_name, :last_name, :date_created]
  end

  def retrieve_ec_query(project_id)

    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = EasyContactQuery.where(cond).find(params[:query_id])
      raise ::Unauthorized unless @query.visible?
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    elsif api_request? || params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = EasyContactQuery.new(:name => "__")
      @query.project = @project
      @query.build_from_params(params)

      @query.column_names=ec_default_fields

      session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
    else
      # retrieve from session
      @query = nil
      @query = EasyContactQuery.find_by_id(session[:query][:id]) if session[:query][:id]
      @query ||= EasyContactQuery.new(:name => "__", :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
      @query.project = @project
    end

  end

end