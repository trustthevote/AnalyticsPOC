include ActionView::Helpers::NumberHelper

class ElectionsController < ApplicationController

  # GET /elections
  def index
    @elections = Election.all
    @showxml = params[:show_xml]

    eid = (Election.all.length == 1 ? Election.all[0].id : params[:id])
    if (params[:select] || Election.all.length == 1)
      @election = Election.find(eid)
      if (Selection.all.length == 0)
        se = Selection.new(:eid => @election.id)
      else
        se = Selection.all[0]
        se.eid = @election.id
      end
      se.save
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "elections.xml", xml
      end
    end
  end

  # GET /elections/1
  def show
    @election = Election.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "election.xml", xml
      end
    end
  end

  # GET /elections/new
  def new
    @election = Election.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /elections/1/edit
  def edit
    @election = Election.find(params[:id])
  end

  # POST /elections
  def create
    @election = Election.new(params[:election])

    respond_to do |format|
      if @election.save
        format.html { redirect_to @election, notice: 'Election was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /elections/1
  def update
    @election = Election.find(params[:id])

    respond_to do |format|
      if @election.update_attributes(params[:election])
        format.html { redirect_to @election, notice: 'Election was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /elections/1
  def destroy
    @election = Election.find(params[:id])
    @election.destroy

    did = params[:id]
    if ((Selection.all.length > 0) &&
        ((Selection.all[0].eid == did) || (Election.all.length == 0)))
      se = Selection.all[0]
      se.eid = nil
      se.save
    end
    
    respond_to do |format|
      format.html { redirect_to elections_url }
    end
  end

end
