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

  def index
    @econtacts = EasyContact.all
    respond_to do |format|
      format.html 
      format.json { render json: @econtacts }
    end
  end

  def show
    @econtact = EasyContact.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def new
    @econtact = EasyContact.new
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def edit
    @econtact = EasyContact.find(params[:id])
  end

  def create
    # 2do validate params
    # possible to use strong parameters params[:easy_contact].permit(:first_name,:last_name,:date_created)

    @econtact = EasyContact.new({:first_name => params[:easy_contact][:first_name],
                                 :last_name=>params[:easy_contact][:last_name]})
#                                 :date_created=>},
#                                 :project_id=>)

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
    @econtact = EasyContact.find(params[:id])

    respond_to do |format|
      if @econtact.update_attributes(params[:easy_contact])
        format.html { redirect_to action: 'show', id: @econtact.id, notice: 'Contact record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @econtact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @econtact = EasyContact.find(params[:id])
    @econtact.destroy

    respond_to do |format|
      format.html { redirect_to easy_contacts_url }
      format.json { head :no_content }
    end
  end

end
