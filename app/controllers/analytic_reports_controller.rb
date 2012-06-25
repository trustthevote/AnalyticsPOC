class AnalyticReportsController < ApplicationController

  def analytic
    if params[:id] 
      eid = params[:id]
    else
      raise Exception, "No Election ID provided"
    end
    @election = Election.find(eid)
    render '/analytic_reports/analytic'
  end

  # GET /analytic_reports
  def index
    #@election = Election.find(params[:eid])

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
    self.report()
    respond_to do |f|
      f.html { render '/analytic_reports/report'+@rn.to_s }
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
      @uv, @uvm = 0, 0
      VoterRecord.all.each do |vr|
        if (vr.vtype=="UOCAVA")
          @uv += 1
          if (vr.other =~ /military/i)
            @uvm += 1
          end
         end
      end
      @uvo = @uv - @uvm
      @uvmp = (@uv==0 ? "0%" : ((100*@uvm)/@uv).to_s+"%")
      @uvop = (@uv==0 ? "0%" : ((100*@uvo)/@uv).to_s+"%")
      @uvoters = []
      @election.voters.each do |v|
        if (v.vtype=~/UOCAVA/)
          @uvoters.push(v)
        end
      end
      self.reportu()
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

  def reportu()

    @su1 = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
       end ? 1 : 0)
    end
    @su2 = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         ((vtr.form =~ /Voter/ || vtr.form =~ /Request/) &&
          vtr.action == "complete")
       end ? 1 : 0)
    end
    @su3 = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Absentee Ballot/)
       end ? 1 : 0)
    end
    @su4 = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
       end ? 1 : 0)
    end

    @vr1 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Registration/ && vtr.action == "complete")
          @vr1 += 1
        end
      end
    end
    @vr2 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Registration/ && vtr.action == "match")
          @vr2 += 1
        end
      end
    end
    @vr3 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Registration/ && vtr.action == "approve")
          @vr3 += 1
        end
      end
    end
    @vr4 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Registration/ && vtr.action == "reject")
          @vr4 += 1
        end
      end
    end
    @vr5 = @vr1-@vr2
    @vr6 = 0
    nvoters = VoterRecord.count
    if nvoters > 0
      @vr6 = (100*@vr3)/nvoters
    end
    @vr6 = @vr6.to_s+"%"
    @vu1 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Record Update/ && vtr.action == "complete")
          @vu1 += 1
        end
      end
    end
    @vu2 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Record Update/ && vtr.action == "match")
          @vu2 += 1
        end
      end
    end
    @vu3 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Record Update/ && vtr.action == "approve")
          @vu3 += 1
        end
      end
    end
    @vu4 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Record Update/ && vtr.action == "reject")
          @vu4 += 1
        end
      end
    end
    @vu5 = @vu1-@vu2
    @ar1 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Request/ && vtr.action == "complete")
          @ar1 += 1
        end
      end
    end
    @ar2 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Request/ && vtr.action == "match")
          @ar2 += 1
        end
      end
    end
    @ar3 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Request/ && vtr.action == "approve")
          @ar3 += 1
        end
      end
    end
    @ar4 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Request/ && vtr.action == "reject")
          @ar4 += 1
        end
      end
    end
    @ar5 = @ar1-@ar2
    @uab_generated = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
          @uab_generated +=  1
        end
      end
    end
    @uab_received, @uab_receivedm = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "match")
          @uab_received += 1
          @uab_receivedm += 1 if (v.vother =~ /military/i)
        end
      end
    end
    @uab_receivedo = @uab_received - @uab_receivedm
    @uab_receivedmp = (@uab_received==0 ? "0%" : ((100*@uab_receivedm)/@uab_received).to_s+"%")
    @uab_receivedop = (@uab_received==0 ? "0%" : ((100*@uab_receivedo)/@uab_received).to_s+"%")
    @uab_approved, @uab_approvedm = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "approve")
          @uab_approved += 1
          @uab_approvedm += 1 if (v.vother =~ /military/i)
        end
      end
    end
    @uab_approvedo = @uab_approved - @uab_approvedm
    @uab_rejected, @uab_rejectedm, @uab_rejectedla, @uab_rejectedlam = 0, 0, 0, 0
    @uab_rejectedgm, @uab_rejectedgf, @uab_rejectedpd, @uab_rejectedpr = 0, 0, 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "reject")
          @uab_rejected += 1
          @uab_rejectedgm += 1 if (v.vgender == 'M')
          @uab_rejectedgf += 1 if (v.vgender == 'F')
          @uab_rejectedpd += 1 if (v.vparty =~ /democrat/i)
          @uab_rejectedpr += 1 if (v.vparty =~ /republic/i)
          if (vtr.note =~ /late/)
            @uab_rejectedla += 1
            @uab_rejectedlam += 1 if (v.vother =~ /military/i)
          end
        end
      end
    end
    @uab_rejectedo = @uab_rejected - @uab_rejectedm
    @uab_rejectedlao = @uab_rejectedla - @uab_rejectedlam
    @uab_lost = @uab_generated-@uab_received
    @sr1 = @vr1+@vu1+@ar1+@uab_generated
    @sr2 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if ((vtr.form =~ /Voter/ || vtr.form =~ /Request/) &&
            vtr.action == "match")
          @sr2 += 1
        end
      end
    end
    @sr3 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if ((vtr.form =~ /Voter/ || vtr.form =~ /Request/) &&
            (vtr.action == "approve"))
          @sr3 += 1
        end
      end
    end
    @sr4 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if ((vtr.form =~ /Voter/ || vtr.form =~ /Request/) &&
            (vtr.action == "reject"))
          @sr4 += 1
        end
      end
    end
    @sr5 = @sr1 - @sr2
    @sr6 = 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
          @sr6 += 1
        end
      end
    end
    @sr7 = @su4
    @sr8 = 0
    @uvoters.each do |v|
      found = 0
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
          found += 1
        end
      end
      if found > 1
        @sr8 += 1
      end
    end
    @uv1p = (@uv==0 ? "0%" : ((100*@su1)/@uv).to_s+"%")
    @uv2p = (@uv==0 ? "0%" : ((100*@su2)/@uv).to_s+"%")
    @uv3p = (@uv==0 ? "0%" : ((100*@su3)/@uv).to_s+"%")
    @uv4p = (@uv==0 ? "0%" : ((100*@su4)/@uv).to_s+"%")
    @su2p = (@su1==0 ? "0%" : ((100*@su2)/@su1).to_s+"%")
    @su4p = (@su1==0 ? "0%" : ((100*@su4)/@su1).to_s+"%")
    @vr3p = "("+(@vr2==0 ? "0" : ((100*@vr3)/@vr2).to_s)+"%)"
    @vr4p = "("+(@vr2==0 ? "0" : ((100*@vr4)/@vr2).to_s)+"%)"
    @vr5p = "("+(@vr1==0 ? "0" : ((100*@vr5)/@vr1).to_s)+"% of forms generated)"
    @vu3p = "("+(@vu2==0 ? "0" : ((100*@vu3)/@vu2).to_s)+"%)"
    @vu4p = "("+(@vu2==0 ? "0" : ((100*@vu4)/@vu2).to_s)+"%)"
    @vu5p = "("+(@vu1==0 ? "0" : ((100*@vu5)/@vu1).to_s)+"% of forms generated)"
    @ar3p = "("+(@ar2==0 ? "0" : ((100*@ar3)/@ar2).to_s)+"%)"
    @ar4p = "("+(@ar2==0 ? "0" : ((100*@ar4)/@ar2).to_s)+"%)"
    @ar5p = "("+(@ar1==0 ? "0" : ((100*@ar5)/@ar1).to_s)+"% of forms generated)"
    @uab_approvedp = "("+(@uab_received==0 ? "0" : ((100*@uab_approved)/@uab_received).to_s)+"%)"
    @uab_rejectedp = "("+(@uab_received==0 ? "0" : ((100*@uab_rejected)/@uab_received).to_s)+"%)"
    @uab_lostp = "("+(@uab_generated==0 ? "0" : ((100*@uab_lost)/@uab_generated).to_s)+"% of forms generated)"
    @sr3p = "("+(@sr2==0 ? "0" : ((100*@sr3)/@sr2).to_s)+"%)"
    @sr4p = "("+(@sr2==0 ? "0" : ((100*@sr4)/@sr2).to_s)+"%)"
    @sr5p = "("+(@sr1==0 ? "0" : ((100*@sr5)/@sr1).to_s)+"% of forms generated)"
  end

  # DELETE /analytic_reports/1
  # DELETE /analytic_reports/1.json
  def destroy
    @analytic_report = AnalyticReport.find(params[:id])
    @analytic_report.destroy

    respond_to do |format|
      format.html { redirect_to analytic_reports_url }
      format.json { head :no_content }
    end
  end

end
