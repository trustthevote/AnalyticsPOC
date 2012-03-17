class VoterTransactionLogsController < ApplicationController
  # GET /voter_transaction_logs
  def index
    @voter_transaction_logs = VoterTransactionLog.all
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_logs/1
  def show
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render layout: nil }
    end
  end

  # GET /voter_transaction_logs/new
  def new
    @voter_transaction_log = VoterTransactionLog.new
    @showxml = false

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /voter_transaction_logs/1/edit
  def edit
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    @showxml = false
  end

  # POST /voter_transaction_logs
  def create
    @voter_transaction_log = VoterTransactionLog.new(params[:voter_transaction_log])
    @showxml = false

    respond_to do |format|
      if @voter_transaction_log.save
        format.html { redirect_to @voter_transaction_log, notice: 'Voter transaction log was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /voter_transaction_logs/1
  def update
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    @showxml = false

    respond_to do |format|
      if @voter_transaction_log.update_attributes(params[:voter_transaction_log])
        format.html { redirect_to @voter_transaction_log, notice: 'Voter transaction log was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /voter_transaction_logs/1
  def destroy
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    @voter_transaction_log.destroy
    @showxml = false

    respond_to do |format|
      format.html { redirect_to voter_transaction_logs_url }
    end
  end
end
