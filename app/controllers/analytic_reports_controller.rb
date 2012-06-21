class AnalyticReportsController < ApplicationController
  # GET /analytic_reports
  def index
    @election = Election.find(params[:eid])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /analytic_reports/1
  # def show
  #   @election = Election.find(params[:id])
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @analytic_report }
  #   end
  # end

  def show
    eid = Election.all.find{|e|e.selected}.id
    @election = Election.find(eid)
    @description = []
    @rn = (params[:rn] ? params[:rn].to_i : 1)
    @rn = 1
    self.report()
    respond_to do |f|
      f.html { render '/reports/report'+@rn.to_s }
      f.pdf  { render layout: false }
    end
  end

  def report
    case @rn
    when 1
      self.report1()
    when 2
      self.report2()
    else
      @rn = 1
      self.report1()
    end
  end

  def report1()
    @rname = 'Voter Participation Report'
    @description = ["This report presents voter participation based on the type of vote cast. For absentee and provisional voters, participation is further broken down according to the number of ballots approved or rejected (A/R). There is an additional caterogy of \"whacky\" voters about which nothing is currently know and subsequently nothing reported."]
    @voters   = 0
    @voted    = 0
    @vote_reg = 0
    @vote_upd = 0
    @vote_no  = 0
    @vote_aa  = 0
    @vote_ar  = 0
    @vote_pa  = 0    
    @vote_pr  = 0
    @vote_wac = 0    
    voter_ids = []
    @election.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        vid = vtr.vname
        voter_ids.push(vid) unless voter_ids.include?(vid)
        if vtr.action == "approve"
          if vtr.form =~ /Absentee Ballot/
            @vote_aa += 1
            @voted += 1
          elsif vtr.form =~ /Provisional Ballot/
            @vote_pa += 1
            @voted += 1
          end
        elsif vtr.action == "reject"
          if vtr.form =~ /Absentee Ballot/
            @vote_ar += 1
            @voted += 1
          elsif vtr.form =~ /Provisional Ballot/
            @vote_pr += 1 
            @voted += 1
          end
        elsif vtr.action == "identify"
          if vtr.form =~ /Poll Book/
            @vote_reg += 1
            @voted += 1
          end
        end
      end
    end
    @voters = voter_ids.length
    if @voters > 0
      @vote_no = @voters - @voted
    end
    @nvoters = @voters.to_s
    @nvoted  = @voted.to_s
    @nvote_reg = @vote_reg.to_s
    @nvote_no = @vote_no.to_s
    @nvote_a = (@vote_aa+@vote_ar).to_s
    @nvote_aa = @vote_aa.to_s+" ("+((@vote_aa+@vote_ar)>0 ? (@vote_aa*100/(@vote_aa+@vote_ar)).round.to_s : "0")+"%)"
    @nvote_ar = @vote_ar.to_s+" ("+((@vote_aa+@vote_ar)>0 ? (@vote_ar*100/(@vote_aa+@vote_ar)).round.to_s : "0")+"%)"
    @nvote_p = (@vote_pa+@vote_pr).to_s
    @nvote_pa = @vote_pa.to_s+" ("+((@vote_pa+@vote_pr)>0 ? (@vote_pa*100/(@vote_pa+@vote_pr)).round.to_s : "0")+"%)"
    @nvote_pr = @vote_pr.to_s+" ("+((@vote_pa+@vote_pr)>0 ? (@vote_pr*100/(@vote_pa+@vote_pr)).round.to_s : "0")+"%)"
    @nvote_wac = @vote_wac.to_s
    @pvoters = ((@voters < 1) ? "0%" : "100%")
    @pvote_reg = (@vote_reg*100/[@voters,1].max).round.to_s+"%"
    @pvote_no = (@vote_no*100/[@voters,1].max).round.to_s+"%"
    @pvote_a = ((@vote_aa+@vote_ar)*100/[@voters,1].max).round.to_s+"%"
    @pvote_p = ((@vote_pa+@vote_pr)*100/[@voters,1].max).round.to_s+"%"
    @pvote_wac = (@vote_wac*100/[@voters,1].max).round.to_s+"%"
    return true
  end

  def report2()
    @rname = 'UOCAVA Ballot Return Report'
    @description = ["This report shows voting success for UOCAVA voters.  First we display the number of UOCAVA voters. Then we give the relative percentage (and count) of those who: registered to vote, updated their voter registration, requested and/or updated absentee status, and submitted an absentee ballot. Finally, we give the percentages of absentee ballots approved or rejected."]
    @voters   = 0
    @voted    = 0
    @vote_reg = 0
    @vote_upd = 0
    @vote_no  = 0
    @vote_as  = 0
    @vote_ab  = 0    
    @vote_aa  = 0
    @vote_ar  = 0
    voter_ids = []
    @election.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        vid = vtr.vname
        if vtr.vtype =~ /UOCAVA/
          voter_ids.push(vid) unless voter_ids.include?(vid)
          if vtr.action == 'approve'
            if vtr.form =~ /Absentee Ballot/
              @vote_aa += 1
              @voted += 1
            elsif vtr.form =~ /Absentee Request/
              @vote_as += 1 
              @voted += 1
            elsif vtr.form =~ /Voter Registration/
              @vote_reg += 1 
              @voted += 1
            elsif vtr.form =~ /Voter Record Update/
              @vote_upd += 1 
              @voted += 1
            end
          elsif vtr.action == 'reject'
            if vtr.form =~ /Absentee Ballot/
              @vote_ar += 1
              @voted += 1
            end
          elsif vtr.form =~ /Absentee Ballot/
            if vtr.action == 'match'
              @vote_ab += 1
              @voted += 1
            end
          end
        end
      end
    end
    @voters = voter_ids.length
    if @voters > 0
      @vote_no = @voters - @voted
    end
    @nvoters = @voters.to_s
    @nvote_reg = @vote_reg.to_s
    @nvote_upd = @vote_upd.to_s
    @nvote_as = @vote_as.to_s
    @nvote_ab = @vote_ab.to_s
    @nvote_aa = @vote_aa.to_s
    @nvote_ar = @vote_ar.to_s
    @pvoters = "100%"
    @pvote_reg = (@vote_reg*100/[@voters,1].max).round.to_s+"%"
    @pvote_upd = (@vote_upd*100/[@voters,1].max).round.to_s+"%"
    @pvote_as = (@vote_as*100/[@voters,1].max).round.to_s+"%"
    @pvote_ab = (@vote_ab*100/[@voters,1].max).round.to_s+"%"
    @pvote_aa = (@vote_aa*100/[@voters,1].max).round.to_s+"%"
    @pvote_ar = (@vote_ar*100/[@voters,1].max).round.to_s+"%"
    return true
  end

end
