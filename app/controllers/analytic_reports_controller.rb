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
    when 0
      self.report1()
    else
      @tv, @uv, @uvm = 0, 0, 0
      if VoterRecord.count == 0
        @tv = @election.voters.count
        @election.voters.each do |v|
          if (v.vtype=="UOCAVA")
            @uv += 1
            @uvm += 1 if (v.vother=~/military/i)
          end
        end
      else
        @tv = VoterRecord.count
        VoterRecord.all.each do |vr|
          if (vr.vtype=="UOCAVA")
            @uv += 1
            @uvm += 1 if (vr.other =~ /military/i)
          end
        end
      end
      @uvo = @uv - @uvm
      @uvmp = self.percente(@uvm,@uv)
      @uvop = self.percente(@uvo,@uv)
      @uvoters = []
      @vrr_generated = 0
      @vrr_received = 0
      @vrr_approved = 0
      @vrr_rejected = 0
      @vrr_rejectedgm = 0
      @vrr_rejectedgf = 0
      @vrr_rejectedpd = 0
      @vrr_rejectedpr = 0
      @vru_generated = 0
      @vru_received = 0
      @vru_approved = 0
      @vru_rejected = 0
      @vru_rejectedgm = 0
      @vru_rejectedgf = 0
      @vru_rejectedpd = 0
      @vru_rejectedpr = 0
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
            if (vtr.action=~/complete/)
              @vab_generated +=  1
            elsif (vtr.action=~/match/)
              @vab_received += 1
            elsif (vtr.action=~/approve/)
              @vab_approved += 1
            elsif (vtr.action=~/reject/)
              @vab_rejected += 1
              @vab_rejectedgm += 1 if (v.vgender=='M')
              @vab_rejectedgf += 1 if (v.vgender=='F')
              @vab_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @vab_rejectedpr += 1 if (v.vparty=~/republic/i)
            end
          elsif (vtr.form =~ /Absentee Request/)
            if (vtr.action=~/complete/)
              @var_generated +=  1
            elsif (vtr.action=~/match/)
              @var_received += 1
            elsif (vtr.action=~/approve/)
              @var_approved += 1
            elsif (vtr.action=~/reject/)
              @var_rejected += 1
              @var_rejectedgm += 1 if (v.vgender=='M')
              @var_rejectedgf += 1 if (v.vgender=='F')
              @var_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @var_rejectedpr += 1 if (v.vparty=~/republic/i)
            end
          elsif (vtr.form =~ /Voter Record Update/)
            if (vtr.action=~/complete/)
              @vru_generated +=  1
            elsif (vtr.action=~/match/)
              @vru_received += 1
            elsif (vtr.action=~/approve/)
              @vru_approved += 1
            elsif (vtr.action=~/reject/)
              @vru_rejected += 1
              @vru_rejectedgm += 1 if (v.vgender=='M')
              @vru_rejectedgf += 1 if (v.vgender=='F')
              @vru_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @vru_rejectedpr += 1 if (v.vparty=~/republic/i)
            end
          elsif (vtr.form =~ /Voter Registration/)
            if (vtr.action=~/complete/)
              @vrr_generated +=  1
            elsif (vtr.action=~/match/)
              @vrr_received += 1
            elsif (vtr.action=~/approve/)
              @vrr_approved += 1
            elsif (vtr.action=~/reject/)
              @vrr_rejected += 1
              @vrr_rejectedgm += 1 if (v.vgender=='M')
              @vrr_rejectedgf += 1 if (v.vgender=='F')
              @vrr_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @vrr_rejectedpr += 1 if (v.vparty=~/republic/i)
            end
          end
        end
      end
      @vrr_rejectedpo = @vrr_rejected-(@vrr_rejectedpd+@vrr_rejectedpr)
      @vrr_rejectedgmp = self.percente(@vrr_rejectedgm,@vrr_rejected)
      @vrr_rejectedgfp = self.percente(@vrr_rejectedgf,@vrr_rejected)
      @vrr_rejectedpdp = self.percente(@vrr_rejectedpd,@vrr_rejected)
      @vrr_rejectedprp = self.percente(@vrr_rejectedpr,@vrr_rejected)
      @vrr_rejectedpop = self.percente(@vrr_rejectedpo,@vrr_rejected)
      @vru_rejectedpo = @vru_rejected-(@vru_rejectedpd+@vru_rejectedpr)
      @vru_rejectedgmp = self.percente(@vru_rejectedgm,@vru_rejected)
      @vru_rejectedgfp = self.percente(@vru_rejectedgf,@vru_rejected)
      @vru_rejectedpdp = self.percente(@vru_rejectedpd,@vru_rejected)
      @vru_rejectedprp = self.percente(@vru_rejectedpr,@vru_rejected)
      @vru_rejectedpop = self.percente(@vru_rejectedpo,@vru_rejected)
      @var_rejectedpo = @var_rejected-(@var_rejectedpd+@var_rejectedpr)
      @var_rejectedgmp = self.percente(@var_rejectedgm,@var_rejected)
      @var_rejectedgfp = self.percente(@var_rejectedgf,@var_rejected)
      @var_rejectedpdp = self.percente(@var_rejectedpd,@var_rejected)
      @var_rejectedprp = self.percente(@var_rejectedpr,@var_rejected)
      @var_rejectedpop = self.percente(@var_rejectedpo,@var_rejected)
      @vab_rejectedpo = @vab_rejected-(@vab_rejectedpd+@vab_rejectedpr)
      @vab_rejectedgmp = self.percente(@vab_rejectedgm,@vab_rejected)
      @vab_rejectedgfp = self.percente(@vab_rejectedgf,@vab_rejected)
      @vab_rejectedpdp = self.percente(@vab_rejectedpd,@vab_rejected)
      @vab_rejectedprp = self.percente(@vab_rejectedpr,@vab_rejected)
      @vab_rejectedpop = self.percente(@vab_rejectedpo,@vab_rejected)
      if (@rn==2)
        self.report2()
      else
        self.reportu()
      end
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
        if vtr.action=~/approve/
          if vtr.form =~ /Absentee Ballot/
            @vote_aa += 1
            @voted += 1
          elsif vtr.form =~ /Provisional Ballot/
            @vote_pa += 1
            @voted += 1
          end
        elsif vtr.action=~/reject/
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
    @nvote_aa = @vote_aa.to_s+" "+self.percente_parens(@vote_aa,(@vote_aa+@vote_ar))
    @nvote_ar = @vote_ar.to_s+" "+self.percente_parens(@vote_ar,(@vote_aa+@vote_ar))
    @nvote_p = (@vote_pa+@vote_pr).to_s
    @nvote_pa = @vote_pa.to_s+" "+self.percente_parens(@vote_pa,(@vote_pa+@vote_pr))
    @nvote_pr = @vote_pr.to_s+" "+self.percente_parens(@vote_pr,(@vote_pa+@vote_pr))
    @nvote_wac = @vote_wac.to_s
    @pvoters = ((@voters < 1) ? "0%" : "100%")
    @pvote_reg = self.percente(@vote_reg,@voters)
    @pvote_no = self.percente(@vote_no,@voters)
    @pvote_a = self.percente(@vote_aa+@vote_ar,@voters)
    @pvote_p = self.percente(@vote_pa+@vote_pr,@voters)
    @pvote_wac = self.percente(@vote_wac,@voters)
    return true
  end

  def report2_old()
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
    @pvote_reg = self.percente(@vote_reg,@voters)
    @pvote_upd = self.percente(@vote_upd,@voters)
    @pvote_as = self.percente(@vote_as,@voters)
    @pvote_ab = self.percente(@vote_ab,@voters)
    @pvote_aa = self.percente(@vote_aa,@voters)
    @pvote_ar = self.percente(@vote_ar,@voters)
    return true
  end

  def report2data(v,vhash)
    vhash['tot'] += 1
    vhash['vm'] += 1 if (v.vgender=='M')
    vhash['vf'] += 1 if (v.vgender=='F')
    vhash['von'] += 1 if (v.vonline)
    if (v.vparty=~/democrat/i)
      vhash['vd'] += 1
    elsif (v.vparty=~/republic/i)
      vhash['vr'] += 1
    else
      vhash['vo'] += 1
    end
    if (!v.voted)
      vhash['vno'] += 1
    elsif (!v.vreject)
      vhash['vpb'] += 1 if (v.vform=~/Regular/)
      vhash['vpa'] += 1 if (v.vform=~/Provisional/)
      vhash['vaa'] += 1 if (v.vform=~/Absentee/)
    else
      vhash['vpr'] += 1 if (v.vform=~/Provisional/)
      vhash['varl'] += 1 if (v.vform=~/Absentee/ && v.vnote=~/late/i)
      vhash['varo'] += 1 if (v.vform=~/Absentee/ && !(v.vnote=~/late/i))
    end
  end

  def report2percent(vhash,total)
    return [self.percent(vhash['vm'],total),
            self.percent(vhash['vf'],total),
            self.percent(vhash['vd'],total),
            self.percent(vhash['vr'],total),
            self.percent(vhash['vo'],total),
            self.percent(vhash['von'],total),
            self.percent(total-vhash['von'],total)]
  end

  def report2()
    @avoters = Hash.new { |h, k| h[k] = 0 }
    @vnoruar = Hash.new { |h, k| h[k] = 0 }
    @vrufail = Hash.new { |h, k| h[k] = 0 }
    @vruappr = Hash.new { |h, k| h[k] = 0 }
    @varfail = Hash.new { |h, k| h[k] = 0 }
    @varappr = Hash.new { |h, k| h[k] = 0 }
      #"tot"=>0,"vno"=>0,"vpb"=0,"vpa"=>0,"vpr"=>0,"vaa"=>0,"varl"=>0,"varo"=>0,
      #"von"=>0,"vm"=>0,"vf"=>0,"vd"=>0,"vr"=>0,"vo"=>0
    @election.voters.each do |v|
      @avoters['tot'] += 1
      @avoters['vm']  += 1 if (v.vgender=='M')
      @avoters['vf']  += 1 if (v.vgender=='F')
      @avoters['von'] += 1 if (v.vonline)
      if (v.vparty=~/democrat/i)
        @avoters['vd'] += 1
      elsif (v.vparty=~/republic/i)
        @avoters['vr'] += 1
      else
        @avoters['vo'] += 1
      end
      if (v.vupdate.blank? && v.vabsreq.blank?) # no VRU or ASR
        self.report2data(v,@vnoruar)
      end
      if (!v.vupdate.blank?)
        if (v.vupdate =~ /approve/) # record update approved
          self.report2data(v,@vruappr)
        else # record update tried but not approved
          self.report2data(v,@vrufail)
        end
      end
      if (!v.vabsreq.blank?)
        if (v.vabsreq =~ /approve/) # absentee request approved
          self.report2data(v,@varappr)
        else # absentee request tried but not approved
          self.report2data(v,@varfail)
        end
      end
    end
    @avotersp = self.report2percent(@avoters,@tv)
    @vnoruarp = self.report2percent(@vnoruar,@vnoruar['tot'])
    @vrufailp = self.report2percent(@vrufail,@vrufail['tot'])
    @vruapprp = self.report2percent(@vruappr,@vruappr['tot'])
    @varfailp = self.report2percent(@varfail,@varfail['tot'])
    @varapprp = self.report2percent(@varappr,@varappr['tot'])
  end

  def percente(x,y)
    (y==0 ? "0%" : ((100*x)/y).round.to_s+"%")
  end
  
  def percente_parens(x,y)
    return "("+percente(x,y)+")"
  end

  def extra(x,y)
    return ""
    if true
      return x.to_s+"/"+y.to_s+"= "
    else
      return ""
    end
  end
  
  def percent(x,y)
    return extra(x,y)+(y==0 ? "0%" : ((100*x)/y).round.to_s+"%")
  end
  
  def percent_parens(x,y)
    return "("+percent(x,y)+")"
  end

  def percent_forms(x,y)
    return "("+percent(x,y)+" of forms generated)"
  end

  def reportu()

    # UOCAVA Aggregate Service Requests
    @urm_use = 0
    @urm_complete = 0
    @uam_use = 0
    @uam_complete = 0

    # UOCAVA Online Service Requests
    @usr_received = 0
    @usr_approved = 0
    @usr_rejected = 0
    @usr_ab_downloads = 0
    @usr_ab_doubles = 0

    # UOCAVA Registration Requests
    @urr_generated = 0
    @urr_received, @urr_receivedm = 0, 0
    @urr_approved, @urr_approvedm = 0, 0
    @urr_rejected, @urr_rejectedm, @urr_rejectedla, @urr_rejectedlam = 0, 0, 0, 0
    @urr_rejectedgm, @urr_rejectedgf = 0, 0
    @urr_rejectedpd, @urr_rejectedpr = 0, 0

    # UOCAVA Record Update Requests
    @uru_generated = 0
    @uru_received, @uru_receivedm = 0, 0
    @uru_approved, @uru_approvedm = 0, 0
    @uru_rejected, @uru_rejectedm, @uru_rejectedla, @uru_rejectedlam = 0, 0, 0, 0
    @uru_rejectedgm, @uru_rejectedgf = 0, 0
    @uru_rejectedpd, @uru_rejectedpr = 0, 0

    # UOCAVA Absentee Requests
    @uar_generated = 0
    @uar_received, @uar_receivedm = 0, 0
    @uar_approved, @uar_approvedm = 0, 0
    @uar_rejected, @uar_rejectedm, @uar_rejectedla, @uar_rejectedlam = 0, 0, 0, 0
    @uar_rejectedgm, @uar_rejectedgf = 0, 0
    @uar_rejectedpd, @uar_rejectedpr = 0, 0

    # UOCAVA Absentee Ballots
    @uab_generated = 0
    @uab_received, @uab_receivedm = 0, 0
    @uab_approved, @uab_approvedm = 0, 0
    @uab_rejected, @uab_rejectedm, @uab_rejectedla, @uab_rejectedlam = 0, 0, 0, 0
    @uab_rejectedgm, @uab_rejectedgf = 0, 0
    @uab_rejectedpd, @uab_rejectedpr = 0, 0

    @uvoters.each do |v|
      foundrm, foundrc, foundam, foundac = 0, 0, 0, 0
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
          foundrm += 1
          foundrc += 1 if vtr.action=~/complete/
          @usr_received += 1 if vtr.action=~/match/
          @usr_approved += 1 if vtr.action=~/approve/
          @usr_rejected += 1 if vtr.action=~/reject/
          if (vtr.form =~ /Voter Registration/)
            if (vtr.action=~/complete/)
              @urr_generated +=  1
            elsif (vtr.action=~/match/)
              @urr_received += 1
              @urr_receivedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/approve/)
              @urr_approved += 1
              @urr_approvedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/reject/)
              @urr_rejected += 1
              @urr_rejectedm += 1 if (v.vother=~/military/i)
              @urr_rejectedgm += 1 if (v.vgender=='M')
              @urr_rejectedgf += 1 if (v.vgender=='F')
              @urr_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @urr_rejectedpr += 1 if (v.vparty=~/republic/i)
              if (vtr.note =~ /late/)
                @urr_rejectedla += 1
                @urr_rejectedlam += 1 if (v.vother=~/military/i)
              end
            end
          elsif (vtr.form =~ /Voter Record Update/)
            if (vtr.action=~/complete/)
              @uru_generated +=  1
            elsif (vtr.action=~/match/)
              @uru_received += 1
              @uru_receivedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/approve/)
              @uru_approved += 1
              @uru_approvedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/reject/)
              @uru_rejected += 1
              @uru_rejectedm += 1 if (v.vother=~/military/i)
              @uru_rejectedgm += 1 if (v.vgender=='M')
              @uru_rejectedgf += 1 if (v.vgender=='F')
              @uru_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @uru_rejectedpr += 1 if (v.vparty=~/republic/i)
              if (vtr.note =~ /late/)
                @uru_rejectedla += 1
                @uru_rejectedlam += 1 if (v.vother=~/military/i)
              end
            end
          elsif (vtr.form =~ /Absentee Request/)
            if (vtr.action=~/complete/)
              @uar_generated +=  1
            elsif (vtr.action=~/match/)
              @uar_received += 1
              @uar_receivedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/approve/)
              @uar_approved += 1
              @uar_approvedm += 1 if (v.vother=~/military/i)
            elsif (vtr.action=~/reject/)
              @uar_rejected += 1
              @uar_rejectedm += 1 if (v.vother=~/military/i)
              @uar_rejectedgm += 1 if (v.vgender=='M')
              @uar_rejectedgf += 1 if (v.vgender=='F')
              @uar_rejectedpd += 1 if (v.vparty=~/democrat/i)
              @uar_rejectedpr += 1 if (v.vparty=~/republic/i)
              if (vtr.note =~ /late/)
                @uar_rejectedla += 1
                @uar_rejectedlam += 1 if (v.vother=~/military/i)
              end
            end
          end
        elsif (vtr.form =~ /Absentee Ballot/)
          foundam += 1
          foundac += 1 if vtr.action=~/complete/
          if (vtr.action=~/complete/)
            @uab_generated +=  1
          elsif (vtr.action=~/match/)
            @uab_received += 1
            @uab_receivedm += 1 if (v.vother=~/military/i)
          elsif (vtr.action=~/approve/)
            @uab_approved += 1
            @uab_approvedm += 1 if (v.vother=~/military/i)
          elsif (vtr.action=~/reject/)
            @uab_rejected += 1
            @uab_rejectedm += 1 if (v.vother=~/military/i)
            @uab_rejectedgm += 1 if (v.vgender=='M')
            @uab_rejectedgf += 1 if (v.vgender=='F')
            @uab_rejectedpd += 1 if (v.vparty=~/democrat/i)
            @uab_rejectedpr += 1 if (v.vparty=~/republic/i)
            if (vtr.note =~ /late/)
              @uab_rejectedla += 1
              @uab_rejectedlam += 1 if (v.vother=~/military/i)
            end
          end
        end
      end
      @usr_ab_downloads += foundac
      if foundac > 1
        @usr_ab_doubles += 1
      end
      @urm_use += 1 if foundrm > 0
      @urm_complete += 1 if foundrc > 0
      @uam_use += 1 if foundam > 0
      @uam_complete += 1 if foundac > 0
    end

    @urm_usep = self.percent(@urm_use,@uv)
    @urm_completep = self.percent(@urm_complete,@uv)
    @urm_completep_reg = self.percent(@urm_complete,@urm_use)
    @uam_usep = self.percent(@uam_use,@uv)
    @uam_completep = self.percent(@uam_complete,@uv)
    @uam_completep_reg = self.percent(@uam_complete,@urm_use)
    
    @usr_generated = @urr_generated+@uru_generated+@uar_generated+@uab_generated
    @usr_receivedp = self.percent(@usr_received,@uv)
    @usr_ab_voters = @uam_complete
    @usr_lost = @usr_generated - @usr_received
    @usr_approvedp = self.percent_parens(@usr_approved,@usr_received)
    @usr_rejectedp = self.percent_parens(@usr_rejected,@usr_received)
    @usr_lostp = self.percent_forms(@usr_lost,@usr_generated)

    @urr_receivedp = self.percent(@urr_received,@uv)
    @urr_receivedo = @urr_received - @urr_receivedm
    @urr_receivedmp = self.percent(@urr_receivedm,@urr_received)
    @urr_receivedop = self.percent(@urr_receivedo,@urr_received)
    @urr_approvedo = @urr_approved - @urr_approvedm
    @urr_approvedop = self.percent(@urr_approvedo,@urr_approved)
    @urr_approvedmp = self.percent(@urr_approvedm,@urr_approved)
    @urr_rejectedpo = @urr_rejected-(@urr_rejectedpd+@urr_rejectedpr)
    @urr_rejectedgmp = self.percente(@urr_rejectedgm,@urr_rejected)
    @urr_rejectedgfp = self.percente(@urr_rejectedgf,@urr_rejected)
    @urr_rejectedpdp = self.percente(@urr_rejectedpd,@urr_rejected)
    @urr_rejectedprp = self.percente(@urr_rejectedpr,@urr_rejected)
    @urr_rejectedpop = self.percente(@urr_rejectedpo,@urr_rejected)
    @urr_rejectedo = @urr_rejected - @urr_rejectedm
    @urr_rejectedop = self.percent(@urr_rejectedo,@urr_rejected)
    @urr_rejectedmp = self.percent(@urr_rejectedm,@urr_rejected)
    @urr_rejectedlao = @urr_rejectedla - @urr_rejectedlam
    @urr_lost = @urr_generated-@urr_received
    @urr_approvedp = self.percent_parens(@urr_approved,@urr_received)
    @urr_rejectedp = self.percent_parens(@urr_rejected,@urr_received)
    @urr_lostp = self.percent_forms(@urr_lost,@urr_generated)
    @urr_new = self.percent(@urr_approved,@tv)

    @uru_receivedp = self.percent(@uru_received,@uv)
    @uru_receivedo = @uru_received - @uru_receivedm
    @uru_receivedmp = self.percent(@uru_receivedm,@uru_received)
    @uru_receivedop = self.percent(@uru_receivedo,@uru_received)
    @uru_approvedo = @uru_approved - @uru_approvedm
    @uru_approvedop = self.percent(@uru_approvedo,@uru_approved)
    @uru_approvedmp = self.percent(@uru_approvedm,@uru_approved)
    @uru_rejectedpo = @uru_rejected-(@uru_rejectedpd+@uru_rejectedpr)
    @uru_rejectedgmp = self.percente(@uru_rejectedgm,@uru_rejected)
    @uru_rejectedgfp = self.percente(@uru_rejectedgf,@uru_rejected)
    @uru_rejectedpdp = self.percente(@uru_rejectedpd,@uru_rejected)
    @uru_rejectedprp = self.percente(@uru_rejectedpr,@uru_rejected)
    @uru_rejectedpop = self.percente(@uru_rejectedpo,@uru_rejected)
    @uru_rejectedo = @uru_rejected - @uru_rejectedm
    @uru_rejectedop = self.percent(@uru_rejectedo,@uru_rejected)
    @uru_rejectedmp = self.percent(@uru_rejectedm,@uru_rejected)
    @uru_rejectedlao = @uru_rejectedla - @uru_rejectedlam
    @uru_lost = @uru_generated-@uru_received
    @uru_approvedp = self.percent_parens(@uru_approved,@uru_received)
    @uru_rejectedp = self.percent_parens(@uru_rejected,@uru_received)
    @uru_lostp = self.percent_forms(@uru_lost,@uru_generated)

    @uar_receivedp = self.percent(@uar_received,@uv)
    @uar_receivedo = @uar_received - @uar_receivedm
    @uar_receivedmp = self.percent(@uar_receivedm,@uar_received)
    @uar_receivedop = self.percent(@uar_receivedo,@uar_received)
    @uar_approvedo = @uar_approved - @uar_approvedm
    @uar_approvedop = self.percent(@uar_approvedo,@uar_approved)
    @uar_approvedmp = self.percent(@uar_approvedm,@uar_approved)
    @uar_rejectedpo = @uar_rejected-(@uar_rejectedpd+@uar_rejectedpr)
    @uar_rejectedgmp = self.percente(@uar_rejectedgm,@uar_rejected)
    @uar_rejectedgfp = self.percente(@uar_rejectedgf,@uar_rejected)
    @uar_rejectedpdp = self.percente(@uar_rejectedpd,@uar_rejected)
    @uar_rejectedprp = self.percente(@uar_rejectedpr,@uar_rejected)
    @uar_rejectedpop = self.percente(@uar_rejectedpo,@uar_rejected)
    @uar_rejectedo = @uar_rejected - @uar_rejectedm
    @uar_rejectedop = self.percent(@uar_rejectedo,@uar_rejected)
    @uar_rejectedmp = self.percent(@uar_rejectedm,@uar_rejected)
    @uar_rejectedlao = @uar_rejectedla - @uar_rejectedlam
    @uar_lost = @uar_generated-@uar_received
    @uar_approvedp = self.percent_parens(@uar_approved,@uar_received)
    @uar_rejectedp = self.percent_parens(@uar_rejected,@uar_received)
    @uar_lostp = self.percent_forms(@uar_lost,@uar_generated)

    @uab_receivedp = self.percent(@uab_received,@uv)
    @uab_receivedo = @uab_received - @uab_receivedm
    @uab_receivedmp = self.percent(@uab_receivedm,@uab_received)
    @uab_receivedop = self.percent(@uab_receivedo,@uab_received)
    @uab_approvedo = @uab_approved - @uab_approvedm
    @uab_approvedop = self.percent(@uab_approvedo,@uab_approved)
    @uab_approvedmp = self.percent(@uab_approvedm,@uab_approved)
    @uab_rejectedpo = @uab_rejected-(@uab_rejectedpd+@uab_rejectedpr)
    @uab_rejectedgmp = self.percente(@uab_rejectedgm,@uab_rejected)
    @uab_rejectedgfp = self.percente(@uab_rejectedgf,@uab_rejected)
    @uab_rejectedpdp = self.percente(@uab_rejectedpd,@uab_rejected)
    @uab_rejectedprp = self.percente(@uab_rejectedpr,@uab_rejected)
    @uab_rejectedpop = self.percente(@uab_rejectedpo,@uab_rejected)
    @uab_rejectedo = @uab_rejected - @uab_rejectedm
    @uab_rejectedop = self.percent(@uab_rejectedo,@uab_rejected)
    @uab_rejectedmp = self.percent(@uab_rejectedm,@uab_rejected)
    @uab_rejectedlao = @uab_rejectedla - @uab_rejectedlam
    @uab_lost = @uab_generated-@uab_received
    @uab_approvedp = self.percent_parens(@uab_approved,@uab_received)
    @uab_rejectedp = self.percent_parens(@uab_rejected,@uab_received)
    @uab_lostp = self.percent_forms(@uab_lost,@uab_generated)

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
