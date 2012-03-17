class VoterTransactionRecordsController < ApplicationController
  # GET /voter_transaction_records
  def index
    @voter_transaction_records = VoterTransactionRecord.all
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_records/1
  def show
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_records/new
  def new
    @voter_transaction_record = VoterTransactionRecord.new
    @showxml = false

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_records/1/edit
  def edit
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
    @showxml = false
  end

  # POST /voter_transaction_records
  def create
    @voter_transaction_record = VoterTransactionRecord.new(params[:voter_transaction_record])
    @showxml = false

    respond_to do |format|
      if @voter_transaction_record.save
        format.html { redirect_to @voter_transaction_record, notice: 'Voter transaction record was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /voter_transaction_records/1
  def update
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
    @showxml = false

    respond_to do |format|
      if @voter_transaction_record.update_attributes(params[:voter_transaction_record])
        format.html { redirect_to @voter_transaction_record, notice: 'Voter transaction record was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /voter_transaction_records/1
  def destroy
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
    @voter_transaction_record.destroy
    @showxml = false

    respond_to do |format|
      format.html { redirect_to voter_transaction_records_url }
    end
  end
end
