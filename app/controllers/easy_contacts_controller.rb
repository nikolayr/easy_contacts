class EasyContactsController < ApplicationController

#  default_search_scope :easy_contacts
  before_filter :authorize#, :except => [:index]
  before_filter :find_project, :authorize, :only => :index

  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid


  helper :custom_fields
  include CustomFieldsHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  include EasyContactQuery

  def index
    @project = Project.find_by_identifier(params[:project_id])

    # @econtacts = EasyContact.all
    #
    # respond_to do |format|
    #   format.html
    #   format.json { render json: @econtacts }
    # end

    #@query is created within retrieve_query
    #retrieve_query # this must be called as retrieve_ec_query
    retrieve_ec_query

    sort_init(@query.sort_criteria.empty? ? [['id']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      case params[:format]
        when 'json'
          @offset, @limit = api_offset_and_limit
          @query.column_names = %w(author_id)
        else
          @limit = per_page_option
      end

      @econtacts_count = @query.contacts_count
      @econtacts_pages = Paginator.new @econtacts_count, @limit, params['page']
      @offset ||= @econtacts_pages.offset
      @econtacts = @query.contacts(:include => [:first_name, :last_name, :date_created],
                              :order => sort_clause,
                              :offset => @offset,
                              :limit => @limit)
      @econtacts_count_by_group = @query.easy_contact_count_by_group

      respond_to do |format|
        format.html { render :template => 'easy_contacts/qindex', :layout => !request.xhr? }
      end
    else
      respond_to do |format|
        format.html { render(:template => 'easy_contacts/index') }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404

  end

  def show
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.find(params[:id])
    @econtact.init_custom_flds

    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def new
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.new
    @econtact.project_id = @project.id

    @econtact.init_custom_flds

    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def edit
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.find(params[:id])
    @econtact.init_custom_flds

    @econtact.project_id = @project.id if @econtact.project_id == 0

  end

  def create

    @project = Project.find_by_identifier(params[:project_id])
    usr_id = User.logged ? User.current.id : 0
#params[:easy_contact][:author_id]
    new_flds = {first_name: params[:easy_contact][:first_name],
                last_name: params[:easy_contact][:last_name],
                project_id: @project.id,
                author_id: usr_id}

    @econtact = EasyContact.new(new_flds)
    @econtact.custom_field_values ||=[]

    if params[:easy_contact].has_key? :custom_field_values
      # TODO save values
      # CustomFieldValue
      @econtact.custom_field_values= params[:easy_contact][:custom_field_values]
    end

    @econtact.save_attachments(params[:attachments] || (params[:easy_contact] && params[:easy_contact][:uploads]))

    respond_to do |format|
      if @econtact.save
        flash[:notice] = l(:notice_contact_record_created)
        format.html { redirect_to  @econtact }
        format.json { render json: @econtact, status: :created, location: @econtact }
      else
        flash[:error] = l(:err_contact_record_not_created)
        format.html { render action: "new" }
        format.json { render json: @econtact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.find(params[:id])
    @econtact.project_id = @project.id if @econtact.project_id == 0

    @econtact.init_custom_flds

    @econtact.custom_field_values=params[:easy_contact][:custom_field_values]

    @econtact.save_attachments(params[:attachments] || (params[:easy_contact] && params[:easy_contact][:uploads]))

    usr_id = User.logged ? User.current.id : 0

    # prepare attr
    ec_data = {first_name: params[:easy_contact][:first_name],
                last_name: params[:easy_contact][:last_name],
                project_id: @project.id,
                author_id: usr_id}

    respond_to do |format|
      if @econtact.update_attributes(ec_data)
        flash[:notice] = l(:notice_contact_record_update)
        format.html { redirect_to action: 'show', id: @econtact.id }
        format.json { head :no_content }
      else
        flash[:error] = l(:err_contact_record_not_updated)
        format.html { render action: 'edit' }
        format.json { render json: @econtact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @econtact = EasyContact.find(params[:id])

    respond_to do |format|
      if @econtact.destroy
        flash[:notice] = l(:notice_contact_record_deleted)
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      else
        flash[:error] = l(:err_contact_record_not_deleted)
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      end

    end
  end

  private

  def find_easy_contact(item_id, proj)
    @econtact = EasyContact.find(item_id)
    @econtact.project = proj
    @econtact.init_custom_flds
  end

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end

  def easy_contact_url(item)
    "#{item.id}"
  end

end
