class EasyContactsController < ApplicationController

#  default_search_scope :easy_contacts
  before_filter :authorize#, :except => [:index]
  before_filter :find_project, :authorize, :only => :index

  accept_api_auth :index, :show, :create, :update, :destroy

  helper :custom_fields
  include CustomFieldsHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

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
    @econtact.project_id = @project.id if @econtact.project_id == 0

#    @econtact.init_custom_flds

  end

  def create
    # 2do validate params
    # possible to use strong parameters params[:easy_contact].permit(:first_name,:last_name,:date_created)

    @project = Project.find_by_identifier(params[:project_id])
    usr_id = User.logged ? User.current.id : 0
#params[:easy_contact][:author_id]
    new_flds = {first_name: params[:easy_contact][:first_name],
                last_name: params[:easy_contact][:last_name],
                project_id: @project.id,
                author_id: usr_id}
#                                 :date_created=>},
#                                 :project_id=>)

    @econtact = EasyContact.new(new_flds)

    # TODO add custom fields to model
    #@econtact.init_custom_flds


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

    #TODO load custom fields values
#    @econtact.init_custom_flds


    @econtact.save_attachments(params[:attachments] || (params[:easy_contact] && params[:easy_contact][:uploads]))

    usr_id = User.logged ? User.current.id : 0

    # prepare attr
    upd_this = {first_name: params[:easy_contact][:first_name],
                last_name: params[:easy_contact][:last_name],
                project_id: @project.id,
                author_id: usr_id}

    respond_to do |format|
      if @econtact.update_attributes(upd_this)
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
  end

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end

  def easy_contact_url(item)
    "#{item.id}"
  end

end
