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
  #   end
  # end

  def show
    eid = Election.all.find{|e|e.selected}.id
    @election = Election.find(eid)
    @description = []
    @rn = (params[:rn] ? params[:rn].to_i : 1)
    @established = false
    self.report()
    respond_to do |f|
      f.html { render '/analytic_reports/report'+@rn.to_s }
      f.pdf  { render layout: false }
    end
  end

  def report()
    if @av = voter_record_report_fetch(@election.id)
      noav = false
    else
      @av = Hash.new {}
      %w(das dda ddo dgf dgm dnw dpd dpo dpr dul dum duo duu tot).each do |k|
        @av[k] = 0
      end
      noav = true
    end
    if @established && @rn>1
      case @rn
      when 2
        self.report2()
      when 3,4
        self.reportuv()
      end
      return
    else
      @trv = (VoterRecord.count==0 ? @election.voters.count : VoterRecord.count)
      @trva, @trdv, @trdva = 0,0,0,0  # Tot Registered/Domestic/Domestic+Abs Voters
      @trvm, @trvf, @trvd, @trvr, @trvo = 0,0,0,0,0
      @tpvm, @tpvf, @tpvd, @tpvr, @tpvo = 0,0,0,0,0
      @trnv, @trnvm, @trnvf, @trnvd, @trnvr, @trnvo = 0,0,0,0,0,0
      @tpnv, @tpnvm, @tpnvf, @tpnvd, @tpnvr, @tpnvo = 0,0,0,0,0,0
      @truv, @truvm, @truvla = 0,0,0# Total UOC/U+mil/U+lapsed+Abs Voters
      @tpv, @tpdv, @tpdvv = 0,0,0  # Tot Registered/Domestic/Domestic+Abs Voters
      @tpdva, @tpdvaa, @tpdvar, @tpdvarl, @tpdvaro = 0,0,0,0,0
      @tpdvp, @tpdvpa, @tpdvpr, @tpdvi = 0,0,0,0
      @tpuv, @tpuvv, @tpuvm, @tpuvla = 0,0,0,0# Total UOC/U+mil/U+lapsed+Abs Voters
      @tpuva, @tpuvr, @tpuvrl, @tpuvro = 0,0,0,0
      @tnv, @tndv, @tndvv = 0,0,0  # Tot Registered/Domestic/Domestic+Abs Voters
      @tndva, @tndvaa, @tndvar, @tndvarl, @tndvaro = 0,0,0,0,0
      @tndvp, @tndvpa, @tndvpr, @tndvi = 0,0,0,0
      @tnuv, @tnuvv, @tnuvm, @tnuvla = 0,0,0,0
      @tnuva, @tnuvr, @tnuvrl, @tnuvro = 0,0,0,0
      @nvrdnp = 0
      @nvuadnp, @nvurdnp, @nvaadnp, @nvardnp = 0, 0, 0, 0
      @election.voters.each do |v|
        if VoterRecord.count==0 && noav
          @av['dgm'] += 1 if v.male
          @av['dgf'] += 1 if v.female
          @av['dpd'] += 1 if v.party_democratic
          @av['dpr'] += 1 if v.party_republican
          @av['dpo'] += 1 if v.party_other
          @av['das'] += 1 if v.absentee_status
        end
        @tnv += 1 if v.new
        if (v.voted)
          @tpv += 1
          @tpvm += 1 if v.male
          @tpvf += 1 if v.female
          @tpvd += 1 if v.party_democratic
          @tpvr += 1 if v.party_republican
          @tpvo += 1 if v.party_other
          if v.new
            @tpnv += 1
            @tpnvm += 1 if v.male 
            @tpnvf += 1 if v.female
            @tpnvd += 1 if v.party_democratic
            @tpnvr += 1 if v.party_republican
            @tpnvo += 1 if v.party_other
          end
        else
          @nvrdnp += 1 if v.new
          @nvuadnp += 1 if v.vru_approved
          @nvurdnp += 1 if v.vru_rejected
          @nvaadnp += 1 if v.asr_approved
          @nvardnp += 1 if v.asr_rejected
        end
        if (v.vtype=="UOCAVA")
          if VoterRecord.count==0 && noav
            @av['duu'] += 1
            @av['dum'] += 1 if v.military
            @av['dul'] += 1 if v.absentee_ulapsed
          end
          @tpuv += 1
          @tpuvv += 1 if v.voted
          @tpuva += 1 if v.ballot_accepted
          @tpuvr += 1 if v.ballot_rejected
          @tpuvrl += 1 if v.ballot_rejected_late
          @tpuvro += 1 if v.ballot_rejected_notlate
          @tpuvm += 1 if v.military
          @tpuvla += 1 if v.absentee_ulapsed
          if v.new
            @tnuv += 1
            @tnuvv += 1 if v.voted
            @tnuva += 1 if v.ballot_accepted
            @tnuvr += 1 if v.ballot_rejected
            @tnuvrl += 1 if v.ballot_rejected_late
            @tnuvro += 1 if v.ballot_rejected_notlate
            @tnuvm += 1 if v.military
            @tnuvla += 1 if v.absentee_ulapsed
          end            
        else
          if VoterRecord.count==0 && noav
            @av['ddo'] += 1
            @av['dda'] += 1 if v.voted_absentee
          end
          @tpdv += 1
          @tpdvv += 1 if v.voted
          if v.new
            @tndv += 1
            @tndvv += 1 if v.voted
          end
          if v.voted_absentee
            @tpdva += 1
            @tpdvaa += 1 if v.ballot_accepted
            @tpdvar += 1 if v.ballot_rejected
            @tpdvarl += 1 if v.ballot_rejected_late
            @tpdvaro += 1 if v.ballot_rejected_notlate
            if v.new
              @tndva += 1
              @tndvaa += 1 if v.ballot_accepted
              @tndvar += 1 if v.ballot_rejected
              @tndvarl += 1 if v.ballot_rejected_late
              @tndvaro += 1 if v.ballot_rejected_notlate
            end
          end
          @tpdvi += 1 if v.voted_inperson
          @tndvi += 1 if v.voted_inperson && v.new
          if v.voted_provisional
            @tpdvp += 1
            @tpdvpa += 1 if v.ballot_accepted
            @tpdvpr += 1 if v.ballot_rejected
            if v.new
              @tndvp += 1
              @tndvpa += 1 if v.ballot_accepted
              @tndvpr += 1 if v.ballot_rejected
            end
          end
        end
      end
      if noav
        @av['duo']   = @av['duu']-@av['dum']
        @av['dum_p'] = self.percent(@av['dum'],@av['duu'])
        @av['duo_p'] = self.percent(@av['duo'],@av['duu'])
        @av['dgm_p'] = self.percent(@av['dgm'],@av['tot'])
        @av['dgf_p'] = self.percent(@av['dgf'],@av['tot'])
        @av['dpd_p'] = self.percent(@av['dpd'],@av['tot'])
        @av['dpr_p'] = self.percent(@av['dpr'],@av['tot'])
        @av['dpo_p'] = self.percent(@av['dpo'],@av['tot'])
      end
      @trnv = @tpnv
      @trnvm = @tpnvm
      @trnvf = @tpnvf
      @trnvd = @tpnvd
      @trnvr = @tpnvr
      @trnvo = @tpnvo
      @tpdvpap = self.percent(@tpdvpa,@tpdvp)
      @tpvp =  self.percent(@tpv,@trv)
      @tpvmp = self.percent(@tpvm,@tpv)
      @tpvfp = self.percent(@tpvf,@tpv)
      @tpvdp = self.percent(@tpvd,@tpv)
      @tpvrp = self.percent(@tpvr,@tpv)
      @tpvop = self.percent(@tpvo,@tpv)
      @tpdvip =  self.percent(@tpdvi,@av['tot'])
      @tpdvap =  self.percent(@tpdva,@av['tot'])
      @tpdvpp =  self.percent(@tpdvp,@av['tot'])
      @tpdvpap = self.percent(@tpdvpa,@tpdvpa+@tpdvpr)
      @tpuvp =   self.percent(@tpuv,@av['tot'])
      @tpuvmp =  self.percent(@tpuvm,@av['tot'])
      @tpuvlap = self.percent(@tpuvla,@av['tot'])
      @avp1p = self.percent(@av['tot']-(@tpdvi+@tpdva+@tpdvp+@tpuvv),@av['tot'])
      @avp2p = self.percent(@tpdvi,@av['tot'])
      @avp3p = self.percent(@tpdvaa+@tpuva,@av['tot'])
      @avp4p = self.percent(@tpdvar+@tpuvr,@av['tot'])
      @avp5p = self.percent(@tpdvpa,@av['tot'])
      @avp6p = self.percent(@tpdvpr,@av['tot'])
      @anp1p = self.percent(@tnv-(@tndvi+@tndva+@tndvp+@tnuvv),@av['tot'])
      @anp2p = self.percent(@tndvi,@tnv)
      @anp3p = self.percent(@tndvaa+@tnuva,@tnv)
      @anp4p = self.percent(@tndvar+@tnuvr,@tnv)
      @anp5p = self.percent(@tndvpa,@tnv)
      @anp6p = self.percent(@tndvpr,@tnv)
      @trnvmp = self.percent(@trnvm,@trnv)
      @trnvfp = self.percent(@trnvf,@trnv)
      @trnvdp = self.percent(@trnvd,@trnv)
      @trnvrp = self.percent(@trnvr,@trnv)
      @trnvop = self.percent(@trnvo,@trnv)
      @tpnvmp = self.percent(@tpnvm,@tpnv)
      @tpnvfp = self.percent(@tpnvf,@tpnv)
      @tpnvdp = self.percent(@tpnvd,@tpnv)
      @tpnvrp = self.percent(@tpnvr,@tpnv)
      @tpnvop = self.percent(@tpnvo,@tpnv)
      @uvoters = []
      @vrrrgentot = 0
      @vrrrrectot = 0
      @vrrrapptot = 0
      @vrrrrejtot = 0
      @vrrrrejdgm = 0
      @vrrrrejdgf = 0
      @vrrrrejdpd = 0
      @vrrrrejdpr = 0
      @vrurgentot = 0
      @vrurrectot = 0
      @vrurapptot = 0
      @vrurrejtot = 0
      @vrurrejdgm = 0
      @vrurrejdgf = 0
      @vrurrejdpd = 0
      @vrurrejdpr = 0
      @vparrgentot = 0
      @vparrrectot = 0
      @vparrapptot = 0
      @vparrrejtot = 0
      @vparrrejdgm = 0
      @vparrrejdgf = 0
      @vparrrejdpd = 0
      @vparrrejdpr = 0
      @vabrgentot = 0
      @vabrrectot = 0
      @vabrapptot = 0
      @vabrrejtot = 0
      @vabrrejdgm = 0
      @vabrrejdgf = 0
      @vabrrejdpd = 0
      @vabrrejdpr = 0
      @election.voters.each do |v|
        if (v.vtype=~/UOCAVA/)
          @uvoters.push(v)
        end
        v.vtrs.each do |vtr|
          if (vtr.form =~ /Absentee Ballot/)
            if (vtr.action=~/complete/)
              @vabrgentot +=  1
            elsif (vtr.action=~/match/)
              @vabrrectot += 1
            elsif (vtr.action=~/approve/)
              @vabrapptot += 1
            elsif (vtr.action=~/reject/)
              @vabrrejtot += 1
              @vabrrejdgm += 1 if v.male
              @vabrrejdgf += 1 if v.female
              @vabrrejdpd += 1 if v.party_democratic
              @vabrrejdpr += 1 if v.party_republican
            end
          elsif (vtr.form =~ /Absentee Request/)
            if (vtr.action=~/complete/)
              @vparrgentot +=  1
            elsif (vtr.action=~/match/)
              @vparrrectot += 1
            elsif (vtr.action=~/approve/)
              @vparrapptot += 1
            elsif (vtr.action=~/reject/)
              @vparrrejtot += 1
              @vparrrejdgm += 1 if v.male
              @vparrrejdgf += 1 if v.female
              @vparrrejdpd += 1 if v.party_democratic
              @vparrrejdpr += 1 if v.party_republican
            end
          elsif (vtr.form =~ /Voter Record Update/)
            if (vtr.action=~/complete/)
              @vrurgentot +=  1
            elsif (vtr.action=~/match/)
              @vrurrectot += 1
            elsif (vtr.action=~/approve/)
              @vrurapptot += 1
            elsif (vtr.action=~/reject/)
              @vrurrejtot += 1
              @vrurrejdgm += 1 if v.male
              @vrurrejdgf += 1 if v.female
              @vrurrejdpd += 1 if v.party_democratic
              @vrurrejdpr += 1 if v.party_republican
            end
          elsif (vtr.form =~ /Voter Registration/)
            if (vtr.action=~/complete/)
              @vrrrgentot +=  1
            elsif (vtr.action=~/match/)
              @vrrrrectot += 1
            elsif (vtr.action=~/approve/)
              @vrrrapptot += 1
            elsif (vtr.action=~/reject/)
              @vrrrrejtot += 1
              @vrrrrejdgm += 1 if v.male
              @vrrrrejdgf += 1 if v.female
              @vrrrrejdpd += 1 if v.party_democratic
              @vrrrrejdpr += 1 if v.party_republican
            end
          end
        end
      end
      @vrrrrejdpo = @vrrrrejtot-(@vrrrrejdpd+@vrrrrejdpr)
      @vrrrrejdgmp = self.percent(@vrrrrejdgm,@vrrrrejtot)
      @vrrrrejdgfp = self.percent(@vrrrrejdgf,@vrrrrejtot)
      @vrrrrejdpdp = self.percent(@vrrrrejdpd,@vrrrrejtot)
      @vrrrrejdprp = self.percent(@vrrrrejdpr,@vrrrrejtot)
      @vrrrrejdpop = self.percent(@vrrrrejdpo,@vrrrrejtot)
      @vrurrejdpo = @vrurrejtot-(@vrurrejdpd+@vrurrejdpr)
      @vrurrejdgmp = self.percent(@vrurrejdgm,@vrurrejtot)
      @vrurrejdgfp = self.percent(@vrurrejdgf,@vrurrejtot)
      @vrurrejdpdp = self.percent(@vrurrejdpd,@vrurrejtot)
      @vrurrejdprp = self.percent(@vrurrejdpr,@vrurrejtot)
      @vrurrejdpop = self.percent(@vrurrejdpo,@vrurrejtot)
      @vparrrejdpo = @vparrrejtot-(@vparrrejdpd+@vparrrejdpr)
      @vparrrejdgmp = self.percent(@vparrrejdgm,@vparrrejtot)
      @vparrrejdgfp = self.percent(@vparrrejdgf,@vparrrejtot)
      @vparrrejdpdp = self.percent(@vparrrejdpd,@vparrrejtot)
      @vparrrejdprp = self.percent(@vparrrejdpr,@vparrrejtot)
      @vparrrejdpop = self.percent(@vparrrejdpo,@vparrrejtot)
      @vabrrejdpo = @vabrrejtot-(@vabrrejdpd+@vabrrejdpr)
      @vabrrejdgmp = self.percent(@vabrrejdgm,@vabrrejtot)
      @vabrrejdgfp = self.percent(@vabrrejdgf,@vabrrejtot)
      @vabrrejdpdp = self.percent(@vabrrejdpd,@vabrrejtot)
      @vabrrejdprp = self.percent(@vabrrejdpr,@vabrrejtot)
      @vabrrejdpop = self.percent(@vabrrejdpo,@vabrrejtot)
      if (@rn==2)
        self.report2()
      elsif (@rn==3 or @rn==4)
        self.reportuv()
      end
    end
  end

  def report2()
    eid = @election.id
    unless pvr = AnalyticReport.find{|ar|ar.election_id==eid&&ar.num==2}
      raise Exception, "No OV report found for election with id: "+eid
    end
      @vp = Hash.new {}
      report2_init()
      report2_compute()
      pvr.set_data(@vp)
      return
    if (@established && !pvr.stale_data)
      @vp = pvr.get_data
    else
      @vp = Hash.new {}
      report2_init()
      report2_compute()
      pvr.set_data(@vp)
      return
    end
  end

  def report2_init()
    %w(all nra rur rua asr asa).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot don dgm dgf dpd dpr dpo vno vra vpa vaa vpr varl varo).each do |k2|
        @vp[k1][k2] = 0
      end
    end
  end

  def report2_compute()
    @election.voters.each do |v|
      self.report2_data(v,@vp['all'])
      if (v.vupdate.blank? && v.vabsreq.blank?) # no VRU or ASR
        self.report2_data(v,@vp['nra'])
      end
      if (!v.vupdate.blank?)
        if (v.vupdate =~ /approve/) # record update approved
          self.report2_data(v,@vp['rua'])
        else # record update tried but not approved
          self.report2_data(v,@vp['rur'])
        end
      end
      if (!v.vabsreq.blank?)
        if (v.vabsreq =~ /approve/) # absentee request approved
          self.report2_data(v,@vp['asa'])
        else # absentee request tried but not approved
          self.report2_data(v,@vp['asr'])
        end
      end
    end
    %w(all nra rur rua asr asa).each do |k|
      self.report2_percent(k)
    end
    return @vp
  end

  def report2_data(v,vhash)
    vhash['tot'] += 1
    vhash['don'] += 1 if v.vonline
    vhash['dgm'] += 1 if v.male
    vhash['dgf'] += 1 if v.female
    vhash['dpd'] += 1 if v.party_democratic
    vhash['dpr'] += 1 if v.party_republican
    vhash['dpo'] += 1 if v.party_other
    if (!v.voted)
      vhash['vno'] += 1
    elsif (!v.vreject)
      vhash['vra'] += 1 if (v.vform=~/Regular/)
      vhash['vpa'] += 1 if (v.vform=~/Provisional/)
      vhash['vaa'] += 1 if (v.vform=~/Absentee/)
    else
      vhash['vpr'] += 1 if (v.vform=~/Provisional/)
      vhash['varl'] += 1 if (v.vform=~/Absentee/ && v.vnote=~/late/i)
      vhash['varo'] += 1 if (v.vform=~/Absentee/ && !(v.vnote=~/late/i))
    end
  end

  def report2_percent(k)
    total = @vp[k]['tot']
    %w(dgm dgf dpd dpr dpo don).each do |kp|
      @vp[k][kp+'_p'] = percent(@vp[k][kp],total)
    end
    @vp[k]['dox_p'] = percent(total-@vp[k]['don'],total)
  end

  def reportuv()
    eid = @election.id
    unless uvr = AnalyticReport.find{|ar|ar.election_id==eid&&ar.num==3}
      raise Exception, "No UV report found for election with id: "+eid
    end
    if (@established && !uvr.stale_data)
      @vu = uvr.get_data
    else
      @vu = Hash.new {}
      reportuv_init()
      reportuv_compute()
      uvr.set_data(@vu)
    end
  end

  def reportuv_init()
    %w(aab aas arr aru).each do |k1|
      @vu[k1] = Hash.new {}
      %w(rapp rrec rrej).each do |k2|
        @vu[k1][k2] = Hash.new {}
        %w(dum duo tot).each do |k3|
          @vu[k1][k2][k3] = 0  
          @vu[k1][k2][k3+'_p'] = "0%"
        end
      end
      k2 = 'rrej'
      %w(dgf dgm dpd dpr dpo).each do |k3|
        @vu[k1][k2][k3] = 0  
        @vu[k1][k2][k3+'_p'] = "0%"
      end
      %w(dla dlm).each do |k3|
        @vu[k1][k2][k3] = 0  
      end
      k2 = 'rgen'
      @vu[k1][k2] = Hash.new {}
      @vu[k1][k2]['tot'] = 0
      k2 = 'rlos'
      @vu[k1][k2] = Hash.new {}
      @vu[k1][k2]['tot'] = 0
      @vu[k1][k2]['tot_p'] = "0%"
    end
    @vu['arr']['rnew'] = Hash.new {}
    @vu['arr']['rnew']['tot_p'] = "0%"

    @vu['aab']['tota'] = Hash.new {}
    @vu['aab']['tota']['tot'] = 0

    @vu['aua'] = Hash.new {}
    @vu['aua']['rcom'] = Hash.new {}
    @vu['aua']['rcom']['tot'] = 0
    @vu['aua']['rcom']['tot_p'] = "0%"
    @vu['aua']['rcom']['tor_p'] = "0%"
    @vu['aua']['tota'] = Hash.new
    @vu['aua']['tota']['tot'] = 0
    @vu['aua']['rdou'] = Hash.new
    @vu['aua']['rdou']['tot'] = 0
    @vu['aua']['rdow'] = Hash.new
    @vu['aua']['rdow']['tot'] = 0

    @vu['aur'] = Hash.new {}
    @vu['aur']['rapp'] = Hash.new {}
    @vu['aur']['rapp']['tot'] = 0
    @vu['aur']['rapp']['tot_p'] = "0%"
    @vu['aur']['tota'] = Hash.new {}
    @vu['aur']['tota']['tot'] = 0
    @vu['aur']['rcom'] = Hash.new {}
    @vu['aur']['rcom']['tot'] = 0
    @vu['aur']['rcom']['tot_p'] = "0%"
    @vu['aur']['rcom']['tor_p'] = "0%"
    @vu['aur']['rgen'] = Hash.new {}
    @vu['aur']['rgen']['tot'] = 0
    @vu['aur']['rlos'] = Hash.new {}
    @vu['aur']['rlos']['tot'] = 0
    @vu['aur']['rlos']['tot_p'] = "0%"
    @vu['aur']['rrec'] = Hash.new {}
    @vu['aur']['rrec']['tot'] = 0
    @vu['aur']['rrec']['tot_p'] = "0%"
    @vu['aur']['rrej'] = Hash.new {}
    @vu['aur']['rrej']['tot'] = 0
    @vu['aur']['rrej']['tot_p'] = "0%"
  end
    
  def reportuv_compute()
    @uvoters.each do |v|
      foundrm, foundrc, foundam, foundac = 0, 0, 0, 0
      v.vtrs.each do |vtr|
        if (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
          foundrm += 1
          foundrc += 1 if vtr.action=~/complete/
          @vu['aur']['rrec']['tot'] += 1 if vtr.action=~/match/
          @vu['aur']['rapp']['tot'] += 1 if vtr.action=~/approve/
          @vu['aur']['rrej']['tot'] += 1 if vtr.action=~/reject/
          if (vtr.form =~ /Voter Registration/)
            if (vtr.action=~/complete/)
              @vu['arr']['rgen']['tot'] +=  1
            elsif (vtr.action=~/match/)
              @vu['arr']['rrec']['tot'] += 1
              @vu['arr']['rrec']['dum'] += 1 if v.military
            elsif (vtr.action=~/approve/)
              @vu['arr']['rapp']['tot'] += 1
              @vu['arr']['rapp']['dum'] += 1 if v.military
            elsif (vtr.action=~/reject/)
              @vu['arr']['rrej']['tot'] += 1
              @vu['arr']['rrej']['dum'] += 1 if v.military
              @vu['arr']['rrej']['dgm'] += 1 if v.male
              @vu['arr']['rrej']['dgf'] += 1 if v.female
              @vu['arr']['rrej']['dpd'] += 1 if v.party_democratic
              @vu['arr']['rrej']['dpr'] += 1 if v.party_republican
              if (vtr.note =~ /late/)
                @vu['arr']['rrej']['dla'] += 1
                @vu['arr']['rrej']['dlm'] += 1 if v.military
              end
            end
          elsif (vtr.form =~ /Voter Record Update/)
            if (vtr.action=~/complete/)
              @vu['aru']['rgen']['tot'] +=  1
            elsif (vtr.action=~/match/)
              @vu['aru']['rrec']['tot'] += 1
              @vu['aru']['rrec']['dum'] += 1 if v.military
            elsif (vtr.action=~/approve/)
              @vu['aru']['rapp']['tot'] += 1
              @vu['aru']['rapp']['dum'] += 1 if v.military
            elsif (vtr.action=~/reject/)
              @vu['aru']['rrej']['tot'] += 1
              @vu['aru']['rrej']['dum'] += 1 if v.military
              @vu['aru']['rrej']['dgm'] += 1 if v.male
              @vu['aru']['rrej']['dgf'] += 1 if v.female
              @vu['aru']['rrej']['dpd'] += 1 if v.party_democratic
              @vu['aru']['rrej']['dpr'] += 1 if v.party_republican
              if (vtr.note =~ /late/)
                @vu['aru']['rrej']['dla'] += 1
                @vu['aru']['rrej']['dlm'] += 1 if v.military
              end
            end
          elsif (vtr.form =~ /Absentee Request/)
            if (vtr.action=~/complete/)
              @vu['aas']['rgen']['tot'] +=  1
            elsif (vtr.action=~/match/)
              @vu['aas']['rrec']['tot'] += 1
              @vu['aas']['rrec']['dum'] += 1 if v.military
            elsif (vtr.action=~/approve/)
              @vu['aas']['rapp']['tot'] += 1
              @vu['aas']['rapp']['dum'] += 1 if v.military
            elsif (vtr.action=~/reject/)
              @vu['aas']['rrej']['tot'] += 1
              @vu['aas']['rrej']['dum'] += 1 if v.military
              @vu['aas']['rrej']['dgm'] += 1 if v.male
              @vu['aas']['rrej']['dgf'] += 1 if v.female
              @vu['aas']['rrej']['dpd'] += 1 if v.party_democratic
              @vu['aas']['rrej']['dpr'] += 1 if v.party_republican
              if (vtr.note =~ /late/)
                @vu['aas']['rrej']['dla'] += 1
                @vu['aas']['rrej']['dlm'] += 1 if v.military
              end
            end
          end
        elsif (vtr.form =~ /Absentee Ballot/)
          foundam += 1
          foundac += 1 if vtr.action=~/complete/
          if (vtr.action=~/complete/)
            @vu['aab']['rgen']['tot'] +=  1
          elsif (vtr.action=~/match/)
            @vu['aab']['rrec']['tot'] += 1
            @vu['aab']['rrec']['dum'] += 1 if v.military
          elsif (vtr.action=~/approve/)
            @vu['aab']['rapp']['tot'] += 1
            @vu['aab']['rapp']['dum'] += 1 if v.military
          elsif (vtr.action=~/reject/)
            @vu['aab']['rrej']['tot'] += 1
            @vu['aab']['rrej']['dum'] += 1 if v.military
            @vu['aab']['rrej']['dgm'] += 1 if v.male
            @vu['aab']['rrej']['dgf'] += 1 if v.female
            @vu['aab']['rrej']['dpd'] += 1 if v.party_democratic
            @vu['aab']['rrej']['dpr'] += 1 if v.party_republican
            if (vtr.note =~ /late/)
              @vu['aab']['rrej']['dla'] += 1
              @vu['aab']['rrej']['dlm'] += 1 if v.military
            end
          end
        end
      end
      @vu['aua']['rdou']['tot'] += foundac
      if foundac > 1
        @vu['aua']['rdow']['tot'] += 1
      end
      @vu['aur']['tota']['tot'] += 1 if foundrm > 0
      @vu['aur']['rcom']['tot'] += 1 if foundrc > 0
      @vu['aua']['tota']['tot'] += 1 if foundam > 0
      @vu['aua']['rcom']['tot'] += 1 if foundac > 0
    end

    @vu['aab']['tota']['tot'] = @vu['aua']['rcom']['tot']

    @vu['aur']['rgen']['tot'] = @vu['arr']['rgen']['tot']+@vu['aru']['rgen']['tot']+@vu['aas']['rgen']['tot']+@vu['aab']['rgen']['tot']
    @vu['aur']['rlos']['tot'] = [@vu['aur']['rgen']['tot']-@vu['aur']['rrec']['tot'],0].max

    @vu['arr']['rlos']['tot'] = [@vu['arr']['rgen']['tot']-@vu['arr']['rrec']['tot'],0].max

    @vu['aru']['rlos']['tot'] = [@vu['aru']['rgen']['tot']-@vu['aru']['rrec']['tot'],0].max

    @vu['aab']['rlos']['tot'] = [@vu['aab']['rgen']['tot']-@vu['aab']['rrec']['tot'],0].max

    @vu['aas']['rlos']['tot'] = [@vu['aab']['rgen']['tot']-@vu['aas']['rrec']['tot'],0].max

    @vu['arr']['rrec']['duo'] = @vu['arr']['rrec']['tot'] - @vu['arr']['rrec']['dum']
    @vu['arr']['rapp']['duo'] = @vu['arr']['rapp']['tot'] - @vu['arr']['rapp']['dum']
    @vu['arr']['rrej']['duo'] = @vu['arr']['rrej']['tot'] - @vu['arr']['rrej']['dum']
    @vu['arr']['rrej']['dpo'] = @vu['arr']['rrej']['tot']-(@vu['arr']['rrej']['dpd']+@vu['arr']['rrej']['dpr'])
    @vu['arr']['rrej']['dlo'] = @vu['arr']['rrej']['dla'] - @vu['arr']['rrej']['dlm']

    @vu['aru']['rapp']['duo'] = @vu['aru']['rapp']['tot'] - @vu['aru']['rapp']['dum']
    @vu['aru']['rrec']['duo'] = @vu['aru']['rrec']['tot'] - @vu['aru']['rrec']['dum']
    @vu['aru']['rrej']['duo'] = @vu['aru']['rrej']['tot'] - @vu['aru']['rrej']['dum']
    @vu['aru']['rrej']['dpo'] = @vu['aru']['rrej']['tot']-(@vu['aru']['rrej']['dpd']+@vu['aru']['rrej']['dpr'])
    @vu['aru']['rrej']['dlo'] = @vu['aru']['rrej']['dla'] - @vu['aru']['rrej']['dlm']

    @vu['aas']['rrec']['duo'] = @vu['aas']['rrec']['tot'] - @vu['aas']['rrec']['dum']
    @vu['aas']['rapp']['duo'] = @vu['aas']['rapp']['tot'] - @vu['aas']['rapp']['dum']
    @vu['aas']['rrej']['duo'] = @vu['aas']['rrej']['tot'] - @vu['aas']['rrej']['dum']
    @vu['aas']['rrej']['dpo'] = @vu['aas']['rrej']['tot']-(@vu['aas']['rrej']['dpd']+@vu['aas']['rrej']['dpr'])
    @vu['aas']['rrej']['dlo'] = @vu['aas']['rrej']['dla'] - @vu['aas']['rrej']['dlm']

    @vu['aab']['rrec']['duo'] = @vu['aab']['rrec']['tot'] - @vu['aab']['rrec']['dum']
    @vu['aab']['rapp']['duo'] = @vu['aab']['rapp']['tot'] - @vu['aab']['rapp']['dum']
    @vu['aab']['rrej']['duo'] = @vu['aab']['rrej']['tot'] - @vu['aab']['rrej']['dum']
    @vu['aab']['rrej']['dpo'] = @vu['aab']['rrej']['tot']-(@vu['aab']['rrej']['dpd']+@vu['aab']['rrej']['dpr'])
    @vu['aab']['rrej']['dlo'] = @vu['aas']['rrej']['dla'] - @vu['aas']['rrej']['dlm']

    @vu['aur']['tota']['tot_p'] = self.percent(@vu['aur']['tota']['tot'],@av['duu'])
    @vu['aur']['rcom']['tot_p'] = self.percent(@vu['aur']['rcom']['tot'],@av['duu'])
    @vu['aur']['rcom']['tor_p'] = self.percent(@vu['aur']['rcom']['tot'],@vu['aur']['tota']['tot'])
    @vu['aua']['tota']['tot_p'] = self.percent(@vu['aua']['tota']['tot'],@av['duu'])
    @vu['aua']['rcom']['tot_p'] = self.percent(@vu['aua']['rcom']['tot'],@av['duu'])
    @vu['aua']['rcom']['tor_p'] = self.percent(@vu['aua']['rcom']['tot'],@vu['aur']['tota']['tot'])
    
    @vu['aur']['rrec']['tot_p'] = self.percent(@vu['aur']['rrec']['tot'],@av['duu'])
    @vu['aur']['rapp']['tot_p'] = self.percent_parens(@vu['aur']['rapp']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rrej']['tot_p'] = self.percent_parens(@vu['aur']['rrej']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rlos']['tot_p'] = self.percent_forms(@vu['aur']['rlos']['tot'],@vu['aur']['rgen']['tot'])

    @vu['arr']['rrec']['tot_p'] = self.percent(@vu['arr']['rrec']['tot'],@av['duu'])
    @vu['arr']['rrec']['dum_p'] = self.percent(@vu['arr']['rrec']['dum'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rrec']['duo_p'] = self.percent(@vu['arr']['rrec']['duo'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rapp']['duo_p'] = self.percent(@vu['arr']['rapp']['duo'],@vu['arr']['rapp']['tot'])
    @vu['arr']['rapp']['dum_p'] = self.percent(@vu['arr']['rapp']['dum'],@vu['arr']['rapp']['tot'])
    @vu['arr']['rrej']['dgm_p'] = self.percent(@vu['arr']['rrej']['dgm'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dgf_p'] = self.percent(@vu['arr']['rrej']['dgf'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dpd_p'] = self.percent(@vu['arr']['rrej']['dpd'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dpr_p'] = self.percent(@vu['arr']['rrej']['dpr'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dpo_p'] = self.percent(@vu['arr']['rrej']['dpo'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['duo_p'] = self.percent(@vu['arr']['rrej']['duo'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dum_p'] = self.percent(@vu['arr']['rrej']['dum'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rapp']['tot_p'] = self.percent_parens(@vu['arr']['rapp']['tot'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rrej']['tot_p'] = self.percent_parens(@vu['arr']['rrej']['tot'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rlos']['tot_p'] = self.percent_forms(@vu['arr']['rlos']['tot'],@vu['arr']['rgen']['tot'])
    @vu['arr']['rnew']['tot_p'] = self.percent(@vu['arr']['rapp']['tot'],@av['tot'])

    @vu['aru']['rrec']['tot_p'] = self.percent(@vu['aru']['rrec']['tot'],@av['duu'])
    @vu['aru']['rrec']['dum_p'] = self.percent(@vu['aru']['rrec']['dum'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rrec']['duo_p'] = self.percent(@vu['aru']['rrec']['duo'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rapp']['duo_p'] = self.percent(@vu['aru']['rapp']['duo'],@vu['aru']['rapp']['tot'])
    @vu['aru']['rapp']['dum_p'] = self.percent(@vu['aru']['rapp']['dum'],@vu['aru']['rapp']['tot'])
    @vu['aru']['rrej']['dgm_p'] = self.percent(@vu['aru']['rrej']['dgm'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dgf_p'] = self.percent(@vu['aru']['rrej']['dgf'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dpd_p'] = self.percent(@vu['aru']['rrej']['dpd'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dpr_p'] = self.percent(@vu['aru']['rrej']['dpr'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dpo_p'] = self.percent(@vu['aru']['rrej']['dpo'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['duo_p'] = self.percent(@vu['aru']['rrej']['duo'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dum_p'] = self.percent(@vu['aru']['rrej']['dum'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rapp']['tot_p'] = self.percent_parens(@vu['aru']['rapp']['tot'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rrej']['tot_p'] = self.percent_parens(@vu['aru']['rrej']['tot'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rlos']['tot_p'] = self.percent_forms(@vu['aru']['rlos']['tot'],@vu['aru']['rgen']['tot'])

    @vu['aas']['rrec']['tot_p'] = self.percent(@vu['aas']['rrec']['tot'],@av['duu'])
    @vu['aas']['rrec']['dum_p'] = self.percent(@vu['aas']['rrec']['dum'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rrec']['duo_p'] = self.percent(@vu['aas']['rrec']['duo'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rapp']['duo_p'] = self.percent(@vu['aas']['rapp']['duo'],@vu['aas']['rapp']['tot'])
    @vu['aas']['rapp']['dum_p'] = self.percent(@vu['aas']['rapp']['dum'],@vu['aas']['rapp']['tot'])
    @vu['aas']['rrej']['dgm_p'] = self.percent(@vu['aas']['rrej']['dgm'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dgf_p'] = self.percent(@vu['aas']['rrej']['dgf'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dpd_p'] = self.percent(@vu['aas']['rrej']['dpd'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dpr_p'] = self.percent(@vu['aas']['rrej']['dpr'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dpo_p'] = self.percent(@vu['aas']['rrej']['dpo'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['duo_p'] = self.percent(@vu['aas']['rrej']['duo'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dum_p'] = self.percent(@vu['aas']['rrej']['dum'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rapp']['tot_p'] = self.percent_parens(@vu['aas']['rapp']['tot'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rrej']['tot_p'] = self.percent_parens(@vu['aas']['rrej']['tot'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rlos']['tot_p'] = self.percent_forms(@vu['aas']['rlos']['tot'],@vu['aas']['rgen']['tot'])

    @vu['aab']['rrec']['tot_p'] = self.percent(@vu['aab']['rrec']['tot'],@av['duu'])
    @vu['aab']['rrec']['dum_p'] = self.percent(@vu['aab']['rrec']['dum'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rrec']['duo_p'] = self.percent(@vu['aab']['rrec']['duo'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rapp']['duo_p'] = self.percent(@vu['aab']['rapp']['duo'],@vu['aab']['rapp']['tot'])
    @vu['aab']['rapp']['dum_p'] = self.percent(@vu['aab']['rapp']['dum'],@vu['aab']['rapp']['tot'])
    @vu['aab']['rrej']['dgm_p'] = self.percent(@vu['aab']['rrej']['dgm'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dgf_p'] = self.percent(@vu['aab']['rrej']['dgf'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dpd_p'] = self.percent(@vu['aab']['rrej']['dpd'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dpr_p'] = self.percent(@vu['aab']['rrej']['dpr'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dpo_p'] = self.percent(@vu['aab']['rrej']['dpo'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['duo_p'] = self.percent(@vu['aab']['rrej']['duo'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dum_p'] = self.percent(@vu['aab']['rrej']['dum'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rapp']['tot_p'] = self.percent_parens(@vu['aab']['rapp']['tot'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rrej']['tot_p'] = self.percent_parens(@vu['aab']['rrej']['tot'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rlos']['tot_p'] = self.percent_forms(@vu['aab']['rlos']['tot'],@vu['aab']['rgen']['tot'])
    return @vu
  end

  # DELETE /analytic_reports/1
  def destroy
    @analytic_report = AnalyticReport.find(params[:id])
    @analytic_report.destroy

    respond_to do |format|
      format.html { redirect_to analytic_reports_url }
    end
  end

end
