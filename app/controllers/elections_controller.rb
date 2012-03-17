class ElectionsController < ApplicationController
  # GET /elections
  def index
    @elections = Election.all
    @showxml = params[:show_xml]

    eid = (Election.all.length == 1 ? Election.all[0].id : params[:id])
    if (params[:select] || Election.all.length == 1)
      @election = Election.find(eid)
      ename = @election.name+" ("+@election.day.to_s+")"
      if (Selection.all.length == 0)
        se = Selection.new(:eid => @election.id, :ename => ename)
      else
        se = Selection.all[0]
        se.eid = @election.id
        se.ename = ename
      end
      se.save
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /elections/1
  def show
    @election = Election.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /elections/new
  def new
    @election = Election.new
    @showxml = false

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /elections/1/edit
  def edit
    @election = Election.find(params[:id])
    @showxml = false
  end

  # POST /elections
  def create
    @election = Election.new(params[:election])
    @showxml = false

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
    @showxml = false

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
    @showxml = false

    did = params[:id]
    if ((Selection.all.length > 0) &&
        ((Selection.all[0].eid == did) || (Election.all.length == 0)))
      se = Selection.all[0]
      se.eid = nil
      se.ename = "None Selected"
      se.save
    end
    
    respond_to do |format|
      format.html { redirect_to elections_url }
    end
  end

end
