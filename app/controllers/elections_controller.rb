include ActionView::Helpers::NumberHelper

class ElectionsController < ApplicationController

  # GET /elections
  def index

    @elections = Election.all
    @showxml = params[:show_xml]

    eid = params[:id]
    if params[:select]
      self.unselect_others(eid)
      @election = Election.find(eid)
      @election.selected = true
      @election.save
      redirect_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml do
          xml = render_to_string(layout: nil)
          send_xml "elections.xml", xml
        end
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
    @election.selected = true
    @election.elogs = "0"
    @election.erecords = "0"
    @election.evoters = "0"

    respond_to do |format|
      if @election.save
        self.unselect_others(@election.id)
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
    if @election.selected
      self.select_another(eid)
    end
    @election.destroy
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
    if @election.selected
      @election.selected = false
      self.select_another(eid)
    end
    @election.save
    ea = ElectionArchive.new(:eid => eid,
                             :name => @election.name,
                             :day => @election.day,
                             :voter_end_day => @election.voter_end_day,
                             :voter_start_day => @election.voter_start_day,
                             :nlogs => @election.elogs.split(",")[0].to_i,
                             :log_file_names => @election.voter_transaction_logs.collect {|vtl| vtl.archive_name}.join(' '))
    ea.save
    respond_to do |format|
      format.html { redirect_to elections_url }
    end
  end

  def unselect_others(eid)
    if true
      Election.all.each do |e|
        unless (e.id == eid)
          if e.selected
            e.selected = false
            e.save
          end
        end
      end
    end
  end

  def select_another(eid)
    Election.all.each do |e|
      unless (e.archived || e.id == eid)
        e.selected = true
        e.save
        return
      end
    end
  end

end
