class EasyContactsController < ApplicationController
  unloadable

  def index
    @econtacts = EasyContacts.all
    respond_to do |format|
      format.html 
      format.json { render json: @econtacts }
    end
  end

  def show
    @econtact = EasyContacts.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def new
    @econtact = EasyContacts.new
    respond_to do |format|
      format.html
      format.json { render json: @econtact }
    end
  end

  def edit
    @econtact = EasyContacts.find(params[:id])
  end

  def create
    # 2do validate params w

    @econtact = EasyContacts.new({:first_name=>params[:first_name],:last_name=>params[:last_name]})

    respond_to do |format|
      if @econtact.save
        format.html { redirect_to  @econtact, notice: 'Contact record was successfully created.' }
        format.json { render json: @econtact, status: :created, location: @econtact }
      else
        format.html { render action: "new" }
        format.json { render json: @econtact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @econtact = EasyContacts.find(params[:id])

    respond_to do |format|
      if @econtact.update_attributes(params[:easy_contact])
        format.html { redirect_to @econtact, notice: 'Contact record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @econtact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @econtact = EasyContacts.find(params[:id])
    @econtact.destroy

    respond_to do |format|
      format.html { redirect_to easy_contacts_url }
      format.json { head :no_content }
    end
  end

end
