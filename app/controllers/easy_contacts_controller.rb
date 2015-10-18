class EasyContactsController < ApplicationController

  helper :projects
  include ProjectsHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  helper :sort
  include SortHelper

  accept_api_auth :index, :show, :create, :update, :destroy

  before_filter :find_project, :authorize, :only => :index


  def index
    @econtacts = EasyContact.all
    respond_to do |format|
      format.html 
      format.json { render json: @econtacts }
    end
  end

  def show
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def new
    @project = Project.find_by_identifier(params[:project_id])

    @econtact = EasyContact.new
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def edit
    @project = Project.find_by_identifier(params[:project_id])
    @econtact = EasyContact.find(params[:id])
  end

  def create
    # 2do validate params
    # possible to use strong parameters params[:easy_contact].permit(:first_name,:last_name,:date_created)
    @econtact = EasyContact.new({:first_name => params[:easy_contact][:first_name],
                                 :last_name=>params[:easy_contact][:last_name]})
#                                 :date_created=>},
#                                 :project_id=>)
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

    respond_to do |format|
      if @econtact.update_attributes({first_name: params[:easy_contact][:first_name], last_name: params[:easy_contact][:last_name]})
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
        format.html { redirect_to easy_contacts_url }
        format.json { head :no_content }
      end

    end
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end

  def easy_contact_url(item)
    "#{item.id}"
  end

end
