class ElectionArchivesController < ApplicationController
  # GET /election_archives
  # GET /election_archives.json
  def index
    @election_archives = ElectionArchive.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @election_archives }
    end
  end

  # GET /election_archives/1
  # GET /election_archives/1.json
  def show
    @election_archive = ElectionArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @election_archive }
    end
  end

  # GET /election_archives/new
  # GET /election_archives/new.json
  def new
    @election_archive = ElectionArchive.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @election_archive }
    end
  end

  # GET /election_archives/1/edit
  def edit
    @election_archive = ElectionArchive.find(params[:id])
  end

  # POST /election_archives
  # POST /election_archives.json
  def create
    @election_archive = ElectionArchive.new(params[:election_archive])

    respond_to do |format|
      if @election_archive.save
        format.html { redirect_to @election_archive, notice: 'Election archive was successfully created.' }
        format.json { render json: @election_archive, status: :created, location: @election_archive }
      else
        format.html { render action: "new" }
        format.json { render json: @election_archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /election_archives/1
  # PUT /election_archives/1.json
  def update
    @election_archive = ElectionArchive.find(params[:id])
    @election = Election.find(@election_archive.eid)
    @election.archived = false
    @election.selected = (Election.all.none?{|e|e.selected})
    @election.save
    self.destroy(true)
  end

  # DELETE /election_archives/1
  # DELETE /election_archives/1.json
  def destroy(restoring = false)
    @election_archive = ElectionArchive.find(params[:id])
    eid = @election_archive.eid
    @election_archive.destroy
    unless restoring
      @election = Election.find(eid)
      if defined?(@election)
        @election.destroy
      end
    end

    respond_to do |format|
      format.html { redirect_to elections_url }
      format.json { head :no_content }
    end
  end
end
