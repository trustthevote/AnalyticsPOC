class VoterRecordsController < ApplicationController
  # GET /voter_records
  # GET /voter_records.json
  def index
    @voter_records = VoterRecord.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @voter_records }
    end
  end

  # GET /voter_records/1
  # GET /voter_records/1.json
  def show
    @voter_record = VoterRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @voter_record }
    end
  end

  # GET /voter_records/new
  # GET /voter_records/new.json
  def new
    @voter_record = VoterRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @voter_record }
    end
  end

  # GET /voter_records/1/edit
  def edit
    @voter_record = VoterRecord.find(params[:id])
  end

  # POST /voter_records
  # POST /voter_records.json
  def create
    @voter_record = VoterRecord.new(params[:voter_record])

    respond_to do |format|
      if @voter_record.save
        format.html { redirect_to @voter_record, notice: 'Voter record was successfully created.' }
        format.json { render json: @voter_record, status: :created, location: @voter_record }
      else
        format.html { render action: "new" }
        format.json { render json: @voter_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /voter_records/1
  # PUT /voter_records/1.json
  def update
    @voter_record = VoterRecord.find(params[:id])

    respond_to do |format|
      if @voter_record.update_attributes(params[:voter_record])
        format.html { redirect_to @voter_record, notice: 'Voter record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @voter_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voter_records/1
  # DELETE /voter_records/1.json
  def destroy
    @voter_record = VoterRecord.find(params[:id])
    @voter_record.destroy

    respond_to do |format|
      format.html { redirect_to voter_records_url }
      format.json { head :no_content }
    end
  end
end
