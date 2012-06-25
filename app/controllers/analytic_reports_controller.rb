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
      @var_generated = 0
      @var_received = 0
      @var_approved = 0
      @var_rejected = 0
      @var_rejectedgm = 0
      @var_rejectedgf = 0
      @var_rejectedpd = 0
      @var_rejectedpr = 0
      @vab_generated = 0
      @vab_received = 0
      @vab_approved = 0
      @vab_rejected = 0
      @vab_rejectedgm = 0
      @vab_rejectedgf = 0
      @vab_rejectedpd = 0
      @vab_rejectedpr = 0
      @election.voters.each do |v|
        if (v.vtype=~/UOCAVA/)
          @uvoters.push(v)
        end
        v.vtrs.each do |vtr|
          if (vtr.form =~ /Absentee Ballot/)
            if (vtr.action == "complete")
              @vab_generated +=  1
            elsif (vtr.action == "match")
              @vab_received += 1
            elsif (vtr.action == "approve")
              @vab_approved += 1
            elsif (vtr.action == "reject")
              @vab_rejected += 1
              @vab_rejectedgm += 1 if (v.vgender == 'M')
              @vab_rejectedgf += 1 if (v.vgender == 'F')
              @vab_rejectedpd += 1 if (v.vparty =~ /democrat/i)
              @vab_rejectedpr += 1 if (v.vparty =~ /republic/i)
            end
          elsif (vtr.form =~ /Absentee Request/)
            if (vtr.action == "complete")
              @var_generated +=  1
            elsif (vtr.action == "match")
              @var_received += 1
            elsif (vtr.action == "approve")
              @var_approved += 1
            elsif (vtr.action == "reject")
              @var_rejected += 1
              @var_rejectedgm += 1 if (v.vgender == 'M')
              @var_rejectedgf += 1 if (v.vgender == 'F')
              @var_rejectedpd += 1 if (v.vparty =~ /democrat/i)
              @var_rejectedpr += 1 if (v.vparty =~ /republic/i)
            end
          end
        end
      end
      @var_rejectedpo = @var_rejected-(@var_rejectedpd+@var_rejectedpr)
      @var_rejectedgmp = (@var_rejected>0 ? ((100*@var_rejectedgm)/@var_rejected).to_s+"%" : "0%")
      @var_rejectedgfp = (@var_rejected>0 ? ((100*@var_rejectedgf)/@var_rejected).to_s+"%" : "0%")
      @var_rejectedpdp = (@var_rejected>0 ? ((100*@var_rejectedpd)/@var_rejected).to_s+"%" : "0%")
      @var_rejectedprp = (@var_rejected>0 ? ((100*@var_rejectedpr)/@var_rejected).to_s+"%" : "0%")
      @var_rejectedpop = (@var_rejected>0 ? ((100*@var_rejectedpo)/@var_rejected).to_s+"%" : "0%")
      @vab_rejectedpo = @vab_rejected-(@vab_rejectedpd+@vab_rejectedpr)
      @vab_rejectedgmp = (@vab_rejected>0 ? ((100*@vab_rejectedgm)/@vab_rejected).to_s+"%" : "0%")
      @vab_rejectedgfp = (@vab_rejected>0 ? ((100*@vab_rejectedgf)/@vab_rejected).to_s+"%" : "0%")
      @vab_rejectedpdp = (@vab_rejected>0 ? ((100*@vab_rejectedpd)/@vab_rejected).to_s+"%" : "0%")
      @vab_rejectedprp = (@vab_rejected>0 ? ((100*@vab_rejectedpr)/@vab_rejected).to_s+"%" : "0%")
      @vab_rejectedpop = (@vab_rejected>0 ? ((100*@vab_rejectedpo)/@vab_rejected).to_s+"%" : "0%")
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

    @urm_generate = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
       end ? 1 : 0)
    end
    @urm_complete = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         ((vtr.form =~ /Voter/ || vtr.form =~ /Request/) &&
          vtr.action == "complete")
       end ? 1 : 0)
    end
    @uam_generate = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Absentee Ballot/)
       end ? 1 : 0)
    end
    @uam_complete = @uvoters.sum do |v|
      (v.vtrs.any? do |vtr|
         (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
       end ? 1 : 0)
    end
    @urm_completep = (@urm_generate==0 ? "0%" : ((100*@urm_complete)/@urm_generate).to_s+"%")
    @uam_completep = (@urm_generate==0 ? "0%" : ((100*@uam_complete)/@urm_generate).to_s+"%")
    @urm_generatep = (@uv==0 ? "0%" : ((100*@urm_generate)/@uv).to_s+"%")
    @urm_completep = (@uv==0 ? "0%" : ((100*@urm_complete)/@uv).to_s+"%")
    @uam_generatep = (@uv==0 ? "0%" : ((100*@uam_generate)/@uv).to_s+"%")
    @uam_completep = (@uv==0 ? "0%" : ((100*@uam_complete)/@uv).to_s+"%")
    
    # UOCAVA Registration Requests
    @urr_generated = 0
    @urr_received, @urr_receivedm = 0, 0
    @urr_approved, @urr_approvedm = 0, 0
    @urr_rejected, @urr_rejectedm, @urr_rejectedla, @urr_rejectedlam = 0, 0, 0, 0
    @urr_rejectedgm, @urr_rejectedgf = 0, 0
    @urr_rejectedpd, @urr_rejectedpr = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Registration/)
          if (vtr.action == "complete")
            @urr_generated +=  1
          elsif (vtr.action == "match")
            @urr_received += 1
            @urr_receivedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "approve")
            @urr_approved += 1
            @urr_approvedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "reject")
            @urr_rejected += 1
            @urr_rejectedm += 1 if (v.vother =~ /military/i)
            @urr_rejectedgm += 1 if (v.vgender == 'M')
            @urr_rejectedgf += 1 if (v.vgender == 'F')
            @urr_rejectedpd += 1 if (v.vparty =~ /democrat/i)
            @urr_rejectedpr += 1 if (v.vparty =~ /republic/i)
            if (vtr.note =~ /late/)
              @urr_rejectedla += 1
              @urr_rejectedlam += 1 if (v.vother =~ /military/i)
            end
          end
        end
      end
    end
    @urr_receivedo = @urr_received - @urr_receivedm
    @urr_receivedmp = (@urr_received==0 ? "0%" : ((100*@urr_receivedm)/@urr_received).to_s+"%")
    @urr_receivedop = (@urr_received==0 ? "0%" : ((100*@urr_receivedo)/@urr_received).to_s+"%")
    @urr_approvedo = @urr_approved - @urr_approvedm
    @urr_approvedop = (@urr_approved > 0 ? ((100*@urr_approvedo)/@urr_approved).to_s+"%" : "0%")
    @urr_approvedmp = (@urr_approved > 0 ? ((100*@urr_approvedm)/@urr_approved).to_s+"%" : "0%")
    @urr_rejectedpo = @urr_rejected-(@urr_rejectedpd+@urr_rejectedpr)
    @urr_rejectedgmp = (@urr_rejected > 0 ? ((100*@urr_rejectedgm)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedgfp = (@urr_rejected > 0 ? ((100*@urr_rejectedgf)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedpdp = (@urr_rejected > 0 ? ((100*@urr_rejectedpd)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedprp = (@urr_rejected > 0 ? ((100*@urr_rejectedpr)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedpop = (@urr_rejected > 0 ? ((100*@urr_rejectedpo)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedo = @urr_rejected - @urr_rejectedm
    @urr_rejectedop = (@urr_rejected > 0 ? ((100*@urr_rejectedo)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedmp = (@urr_rejected > 0 ? ((100*@urr_rejectedm)/@urr_rejected).to_s+"%" : "0%")
    @urr_rejectedlao = @urr_rejectedla - @urr_rejectedlam
    @urr_lost = @urr_generated-@urr_received
    @urr_approvedp = "("+(@urr_received==0 ? "0" : ((100*@urr_approved)/@urr_received).to_s)+"%)"
    @urr_rejectedp = "("+(@urr_received==0 ? "0" : ((100*@urr_rejected)/@urr_received).to_s)+"%)"
    @urr_lostp = "("+(@urr_generated==0 ? "0" : ((100*@urr_lost)/@urr_generated).to_s)+"% of forms generated)"
    @urr_new = 0
    nvoters = VoterRecord.count
    if nvoters > 0
      @urr_new = (100*@urr_approved)/nvoters
    end
    @urr_new = @urr_new.to_s+"%"

    # UOCAVA Record Update Requests
    @uru_generated = 0
    @uru_received, @uru_receivedm = 0, 0
    @uru_approved, @uru_approvedm = 0, 0
    @uru_rejected, @uru_rejectedm, @uru_rejectedla, @uru_rejectedlam = 0, 0, 0, 0
    @uru_rejectedgm, @uru_rejectedgf = 0, 0
    @uru_rejectedpd, @uru_rejectedpr = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter Record Update/)
          if (vtr.action == "complete")
            @uru_generated +=  1
          elsif (vtr.action == "match")
            @uru_received += 1
            @uru_receivedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "approve")
            @uru_approved += 1
            @uru_approvedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "reject")
            @uru_rejected += 1
            @uru_rejectedm += 1 if (v.vother =~ /military/i)
            @uru_rejectedgm += 1 if (v.vgender == 'M')
            @uru_rejectedgf += 1 if (v.vgender == 'F')
            @uru_rejectedpd += 1 if (v.vparty =~ /democrat/i)
            @uru_rejectedpr += 1 if (v.vparty =~ /republic/i)
            if (vtr.note =~ /late/)
              @uru_rejectedla += 1
              @uru_rejectedlam += 1 if (v.vother =~ /military/i)
            end
          end
        end
      end
    end
    @uru_receivedo = @uru_received - @uru_receivedm
    @uru_receivedmp = (@uru_received==0 ? "0%" : ((100*@uru_receivedm)/@uru_received).to_s+"%")
    @uru_receivedop = (@uru_received==0 ? "0%" : ((100*@uru_receivedo)/@uru_received).to_s+"%")
    @uru_approvedo = @uru_approved - @uru_approvedm
    @uru_approvedop = (@uru_approved > 0 ? ((100*@uru_approvedo)/@uru_approved).to_s+"%" : "0%")
    @uru_approvedmp = (@uru_approved > 0 ? ((100*@uru_approvedm)/@uru_approved).to_s+"%" : "0%")
    @uru_rejectedpo = @uru_rejected-(@uru_rejectedpd+@uru_rejectedpr)
    @uru_rejectedgmp = (@uru_rejected > 0 ? ((100*@uru_rejectedgm)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedgfp = (@uru_rejected > 0 ? ((100*@uru_rejectedgf)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedpdp = (@uru_rejected > 0 ? ((100*@uru_rejectedpd)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedprp = (@uru_rejected > 0 ? ((100*@uru_rejectedpr)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedpop = (@uru_rejected > 0 ? ((100*@uru_rejectedpo)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedo = @uru_rejected - @uru_rejectedm
    @uru_rejectedop = (@uru_rejected > 0 ? ((100*@uru_rejectedo)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedmp = (@uru_rejected > 0 ? ((100*@uru_rejectedm)/@uru_rejected).to_s+"%" : "0%")
    @uru_rejectedlao = @uru_rejectedla - @uru_rejectedlam
    @uru_lost = @uru_generated-@uru_received
    @uru_approvedp = "("+(@uru_received==0 ? "0" : ((100*@uru_approved)/@uru_received).to_s)+"%)"
    @uru_rejectedp = "("+(@uru_received==0 ? "0" : ((100*@uru_rejected)/@uru_received).to_s)+"%)"
    @uru_lostp = "("+(@uru_generated==0 ? "0" : ((100*@uru_lost)/@uru_generated).to_s)+"% of forms generated)"

    # UOCAVA Absentee Requests
    @uar_generated = 0
    @uar_received, @uar_receivedm = 0, 0
    @uar_approved, @uar_approvedm = 0, 0
    @uar_rejected, @uar_rejectedm, @uar_rejectedla, @uar_rejectedlam = 0, 0, 0, 0
    @uar_rejectedgm, @uar_rejectedgf = 0, 0
    @uar_rejectedpd, @uar_rejectedpr = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Request/)
          if (vtr.action == "complete")
            @uar_generated +=  1
          elsif (vtr.action == "match")
            @uar_received += 1
            @uar_receivedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "approve")
            @uar_approved += 1
            @uar_approvedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "reject")
            @uar_rejected += 1
            @uar_rejectedm += 1 if (v.vother =~ /military/i)
            @uar_rejectedgm += 1 if (v.vgender == 'M')
            @uar_rejectedgf += 1 if (v.vgender == 'F')
            @uar_rejectedpd += 1 if (v.vparty =~ /democrat/i)
            @uar_rejectedpr += 1 if (v.vparty =~ /republic/i)
            if (vtr.note =~ /late/)
              @uar_rejectedla += 1
              @uar_rejectedlam += 1 if (v.vother =~ /military/i)
            end
          end
        end
      end
    end
    @uar_receivedo = @uar_received - @uar_receivedm
    @uar_receivedmp = (@uar_received==0 ? "0%" : ((100*@uar_receivedm)/@uar_received).to_s+"%")
    @uar_receivedop = (@uar_received==0 ? "0%" : ((100*@uar_receivedo)/@uar_received).to_s+"%")
    @uar_approvedo = @uar_approved - @uar_approvedm
    @uar_approvedop = (@uar_approved > 0 ? ((100*@uar_approvedo)/@uar_approved).to_s+"%" : "0%")
    @uar_approvedmp = (@uar_approved > 0 ? ((100*@uar_approvedm)/@uar_approved).to_s+"%" : "0%")
    @uar_rejectedpo = @uar_rejected-(@uar_rejectedpd+@uar_rejectedpr)
    @uar_rejectedgmp = (@uar_rejected > 0 ? ((100*@uar_rejectedgm)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedgfp = (@uar_rejected > 0 ? ((100*@uar_rejectedgf)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedpdp = (@uar_rejected > 0 ? ((100*@uar_rejectedpd)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedprp = (@uar_rejected > 0 ? ((100*@uar_rejectedpr)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedpop = (@uar_rejected > 0 ? ((100*@uar_rejectedpo)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedo = @uar_rejected - @uar_rejectedm
    @uar_rejectedop = (@uar_rejected > 0 ? ((100*@uar_rejectedo)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedmp = (@uar_rejected > 0 ? ((100*@uar_rejectedm)/@uar_rejected).to_s+"%" : "0%")
    @uar_rejectedlao = @uar_rejectedla - @uar_rejectedlam
    @uar_lost = @uar_generated-@uar_received
    @uar_approvedp = "("+(@uar_received==0 ? "0" : ((100*@uar_approved)/@uar_received).to_s)+"%)"
    @uar_rejectedp = "("+(@uar_received==0 ? "0" : ((100*@uar_rejected)/@uar_received).to_s)+"%)"
    @uar_lostp = "("+(@uar_generated==0 ? "0" : ((100*@uar_lost)/@uar_generated).to_s)+"% of forms generated)"

    # UOCAVA Absentee Ballots
    @uab_generated = 0
    @uab_received, @uab_receivedm = 0, 0
    @uab_approved, @uab_approvedm = 0, 0
    @uab_rejected, @uab_rejectedm, @uab_rejectedla, @uab_rejectedlam = 0, 0, 0, 0
    @uab_rejectedgm, @uab_rejectedgf = 0, 0
    @uab_rejectedpd, @uab_rejectedpr = 0, 0
    @uvoters.each do |v|
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Absentee Ballot/)
          if (vtr.action == "complete")
            @uab_generated +=  1
          elsif (vtr.action == "match")
            @uab_received += 1
            @uab_receivedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "approve")
            @uab_approved += 1
            @uab_approvedm += 1 if (v.vother =~ /military/i)
          elsif (vtr.action == "reject")
            @uab_rejected += 1
            @uab_rejectedm += 1 if (v.vother =~ /military/i)
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
    end
    @uab_receivedo = @uab_received - @uab_receivedm
    @uab_receivedmp = (@uab_received==0 ? "0%" : ((100*@uab_receivedm)/@uab_received).to_s+"%")
    @uab_receivedop = (@uab_received==0 ? "0%" : ((100*@uab_receivedo)/@uab_received).to_s+"%")
    @uab_approvedo = @uab_approved - @uab_approvedm
    @uab_rejectedpo = @uab_rejected-(@uab_rejectedpd+@uab_rejectedpr)
    @uab_rejectedgmp = (@uab_rejected > 0 ? ((100*@uab_rejectedgm)/@uab_rejected).to_s+"%" : "0%")
    @uab_rejectedgfp = (@uab_rejected > 0 ? ((100*@uab_rejectedgf)/@uab_rejected).to_s+"%" : "0%")
    @uab_rejectedpdp = (@uab_rejected > 0 ? ((100*@uab_rejectedpd)/@uab_rejected).to_s+"%" : "0%")
    @uab_rejectedprp = (@uab_rejected > 0 ? ((100*@uab_rejectedpr)/@uab_rejected).to_s+"%" : "0%")
    @uab_rejectedpop = (@uab_rejected > 0 ? ((100*@uab_rejectedpo)/@uab_rejected).to_s+"%" : "0%")
    @uab_rejectedo = @uab_rejected - @uab_rejectedm
    @uab_rejectedlao = @uab_rejectedla - @uab_rejectedlam
    @uab_lost = @uab_generated-@uab_received
    @uab_approvedp = "("+(@uab_received==0 ? "0" : ((100*@uab_approved)/@uab_received).to_s)+"%)"
    @uab_rejectedp = "("+(@uab_received==0 ? "0" : ((100*@uab_rejected)/@uab_received).to_s)+"%)"
    @uab_lostp = "("+(@uab_generated==0 ? "0" : ((100*@uab_lost)/@uab_generated).to_s)+"% of forms generated)"

    @usr_generated = @urr_generated+@uru_generated+@uar_generated+@uab_generated
    @usr_received = 0
    @usr_approved = 0
    @usr_rejected = 0
    @usr_lost = @usr_generated - @usr_received
    @usr_ab_downloads = 0
    @usr_ab_voters = @uam_complete
    @usr_ab_doubles = 0
    @uvoters.each do |v|
      found = 0
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
          @usr_received += 1 if vtr.action == "match"
          @usr_approved += 1 if vtr.action == "approve"
          @usr_rejected += 1 if vtr.action == "reject"
        elsif (vtr.form =~ /Absentee Ballot/ && vtr.action == "complete")
          @usr_ab_downloads += 1
          found += 1
        end
      end
      if found > 1
        @usr_ab_doubles += 1
      end
    end
    @usr_approvedp = "("+(@usr_received==0 ? "0" : ((100*@usr_approved)/@usr_received).to_s)+"%)"
    @usr_rejectedp = "("+(@usr_received==0 ? "0" : ((100*@usr_rejected)/@usr_received).to_s)+"%)"
    @usr_lostp = "("+(@usr_generated==0 ? "0" : ((100*@usr_lost)/@usr_generated).to_s)+"% of forms generated)"
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
