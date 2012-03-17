class SelectionsController < ApplicationController
  # GET /selections
  def index
    @selections = Selection.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /selections/1
  def show
    @selection = Selection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /selections/new
  def new
    @selection = Selection.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /selections/1/edit
  def edit
    @selection = Selection.find(params[:id])
  end

  # POST /selections
  def create
    @selection = Selection.new(params[:selection])

    respond_to do |format|
      if @selection.save
        format.html { redirect_to @selection, notice: 'Selection was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /selections/1
  def update
    @selection = Selection.find(params[:id])

    respond_to do |format|
      if @selection.update_attributes(params[:selection])
        format.html { redirect_to @selection, notice: 'Selection was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /selections/1
  def destroy
    @selection = Selection.find(params[:id])
    @selection.destroy

    respond_to do |format|
      format.html { redirect_to selections_url }
    end
  end
end
