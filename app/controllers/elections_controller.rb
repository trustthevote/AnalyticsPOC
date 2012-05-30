include ActionView::Helpers::NumberHelper

class ElectionsController < ApplicationController

  # GET /elections
  def index

    @elections = Election.all
    @showxml = params[:show_xml]

    eid = (Election.all.length == 1 ? Election.all[0].id : params[:id])
    if (params[:select] || Election.all.length == 1)
      @election = Election.find(eid)
      self.select_me(eid)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "elections.xml", xml
      end
    end
  end

  # GET /elections/replace
  def replace
    respond_to do |format|
      format.html # replace.html.haml
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
    @election.archived = false
    @election.elogs = "0"
    @election.erecords = "0"
    @election.evoters = "0"

    respond_to do |format|
      if @election.save
        self.select_me(@election.id)
        format.html { redirect_to @election,
          notice: 'Election was successfully created.' }
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
    eid = params[:id]
    @election = Election.find(eid)
    @election.voter_transaction_logs.each do |vtl|
      vtl.delete_archive_file
    end
    @election.destroy
    Selection.all[0].eid = nil
    Selection.all[0].save
    respond_to do |format|
      format.html { redirect_to elections_url }
    end
  end

  # ARCHIVE /elections/1
  def archive
    params[:id] = params[:election_id]
    eid = params[:id]
    @election = Election.find(eid)
    @election.archived = true
    @election.save
    ea = ElectionArchive.new(:eid => eid,
                             :name => @election.name,
                             :day => @election.day,
                             :voter_end_day => @election.voter_end_day,
                             :voter_start_day => @election.voter_start_day,
                             :nlogs => @election.elogs.split(",")[0].to_i,
                             :log_file_names => @election.voter_transaction_logs.collect {|vtl| vtl.archive_name}.join(' '))
    ea.save
    Selection.all[0].eid = nil
    Selection.all[0].save
    respond_to do |format|
      format.html { redirect_to elections_url }
    end
  end

  def select_another(eid)
    return if (Selection.all.length > 0 && Selection.all[0].eid == eid)
    Election.all.each do |e|
      unless (e.archived || e.id == eid)
        return e.select_self()
      end
    end
    self.select_me(nil)
  end

  def select_me(eid)
    if (Selection.all.length == 0)
      se = Selection.new(:eid => eid)
    else
      se = Selection.all[0]
      se.eid = eid
    end
    se.save
  end

  def select_none()
    se = Selection.all[0]
    se.eid = nil
    se.save
  end

end
