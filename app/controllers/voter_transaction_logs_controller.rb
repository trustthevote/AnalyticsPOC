class VoterTransactionLogsController < ApplicationController
  before_filter :authenticate_user!

  # GET /voter_transaction_logs
  def index
    @voter_transaction_logs = VoterTransactionLog.all
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # index.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "voter_transaction_logs.xml", xml
      end
    end
  end

  # GET /voter_transaction_logs/1
  def show
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    @showxml = params[:show_xml]

    respond_to do |format|
      format.html # show.html.erb
      format.xml do
        xml = render_to_string(layout: nil)
        send_xml "voter_transaction_log.xml", xml
      end
    end
  end

  # GET /voter_transaction_logs/new
  def new
    @voter_transaction_log = VoterTransactionLog.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /voter_transaction_logs/1/edit
  def edit
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
  end

  # POST /voter_transaction_logs
  def create
    @voter_transaction_log = VoterTransactionLog.new(params[:voter_transaction_log])

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

    respond_to do |format|
      if @voter_transaction_log.update_attributes(params[:voter_transaction_log])
        format.html { redirect_to @voter_transaction_log, notice: 'Voter transaction log was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /voter_transaction_logs/1
  def destroy(replace = false)
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    e = Election.find(@voter_transaction_log.election_id)
    e.log_del(@voter_transaction_log)
    @voter_transaction_log.vtrs.each do |vtr| # JVC Voter State
      vid = vtr.voter_id
      v = Voter.find(vid)
      v.vtr_state_pop()
      v.save
    end
    @voter_transaction_log.destroy
    # e.voters.all.each do |v| #JVC
    #   if v.voter_transaction_records.count == 0
    #     v.destroy
    #   end
    # end
    e.save

    if replace
      return e
    else
      respond_to do |format|
        format.html { redirect_to e }
      end
    end
  end

  # REPLACE /voter_transaction_logs/1
  def replace
    params[:id] = params[:voter_transaction_log_id]
    @voter_transaction_log = VoterTransactionLog.find(params[:id])
    file_name = @voter_transaction_log.file_name
    e = self.destroy(true)
    respond_to do |format|
      format.html { redirect_to '/elections/replace?file='+file_name }
    end
  end

end
