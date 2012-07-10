class VoterTransactionRecordsController < ApplicationController
  before_filter :authenticate_user!
  # GET /voter_transaction_records
  def index
    if eid = params[:id]
      eid = eid.to_i
      filter = params[:filter]
      @voter_transaction_records = []
      VoterTransactionLog.all.each do |vtl|
        if vtl.archived
        elsif eid == vtl.election_id
          vtl.voter_transaction_records.each do |vtr|
            if filter =~ /uoc/
              @voter_transaction_records.push(vtr) if vtr.vtype=~/UOCAVA/
            elsif filter =~ /abs/
              @voter_transaction_records.push(vtr) if vtr.form=~/Absentee\sBallot/
            else
              @voter_transaction_records.push(vtr)
            end
          end
        end
      end
    else
      @voter_transaction_records = VoterTransactionRecord.all
    end
    @nvtrs = @voter_transaction_records.length
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # index.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "voter_transaction_records.xml", xml
      end
    end
  end

  # GET /voter_transaction_records/1
  def show
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "voter_transaction_record.xml", xml
      end
    end
  end

  # GET /voter_transaction_records/new
  def new
    @voter_transaction_record = VoterTransactionRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_records/1/edit
  def edit
    @voter_transaction_record = VoterTransactionRecord.find(params[:id])
  end

  # POST /voter_transaction_records
  def create
    @voter_transaction_record = VoterTransactionRecord.new(params[:voter_transaction_record])

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
 
    respond_to do |format|
      format.html { redirect_to voter_transaction_records_url }
    end
  end
end
