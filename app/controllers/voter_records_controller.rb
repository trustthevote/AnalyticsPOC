class VoterRecordsController < ApplicationController
  before_filter :current_user!

  # GET /voter_records
  def index
    @voter_records = VoterRecord.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /voter_records/1
  def show
    #@voter_record = VoterRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /voter_records/new
  def new
    @voter_record = VoterRecord.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /voter_records/1/edit
  def edit
    @voter_record = VoterRecord.find(params[:id])
  end

  # POST /voter_records
  def create
    @voter_record = VoterRecord.new(params[:voter_record])

    respond_to do |format|
      if @voter_record.save
        format.html { redirect_to @voter_record, notice: 'Voter record was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /voter_records/1
  def update
    @voter_record = VoterRecord.find(params[:id])

    respond_to do |format|
      if @voter_record.update_attributes(params[:voter_record])
        format.html { redirect_to @voter_record, notice: 'Voter record was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /voter_records/1
  def destroy
    VoterRecord.all.each { |vr| vr.destroy }
    
    respond_to do |format|
      format.html { redirect_to voter_records_url }
    end
  end

end
