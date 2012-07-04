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

# Legend Voters All @va[key]
#   d...key = Demographic ...
# dda Domestic Absentee
# ddo Domestic 
# dgf Gender Female
# dgm Gender Male
# dnw New
# dpd Party Democratic
# dpo Party 3rd
# dpr Party Republican
# dua UOCAVA Absentee
# dul UOCAVA Lapsed
# dum UOCAVA Military
# duo UOCAVA Overseas
# duu UOCAVA
# tot Total

  def report_va_init(eid=false)
    unless @va = report_fetch(1,eid)
      @va = Hash.new {}
      %w(das dda ddo dgf dgm dpd dpo dpr dua dul dum duo duu tot).each do |k|
        @va[k] = 0
      end
      %w(dnw ngf ngm npd npo npr).each do |k|
        @va[k] = 0
      end
      return false
    end
    return true
  end

  def report_vp_init()
    @vp = Hash.new {}
    @vp['vno'] = Hash.new {}
    %w(tot new rua rur asa asr).each{|k|@vp['vno'][k]=0}
    @vp['vno']['new_p'] = "0%"
    %w(vot new).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot dgm dgf dpd dpr dpo vtot).each do |k2|
        @vp[k1][k2] = 0
        @vp[k1][k2+'_p'] = "0%"
      end
    end
    %w(duu dun).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot abl vaa var varl varo vla vm vtot).each{|k2|@vp[k1][k2]=0}
    end
    %w(tot vla vm).each{|kp|@vp['duu'][kp+'_p'] = "0%"}
    %w(ddn ddo).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot va vaa var varl varo vi vp vpa vpr vtot).each do |k2|
        @vp[k1][k2] = 0        
      end
    end
    %w(vi va vaa var vp vpa vpr vpp tot).each do |kp|
      @vp['ddn'][kp+'_p'] = "0%"
      @vp['ddo'][kp+'_p'] = "0%"
    end
    return @vp
  end

  def report()
    if @va = voter_record_report_fetch(@election.id)
      nova = false
    else
      @va = Hash.new {}
      %w(das dda ddo dgf dgm dpd dpo dpr dua dul dum duo duu tot).each do |k|
        @va[k] = 0
      end
      %w(dnw ngf ngm npd npo npr).each do |k|
        @va[k] = 0
      end
      return false
      nova = true
    end
    if @established && @rn>1
      case @rn
      when 2
        self.report2()
      when 3,4
        self.report_vu()
      end
      return
    else
      report_vu_init()
      report_vp_init()
      if false
      @vp['vot']['tot'], @vp['vot']['dgm'], @vp['vot']['dgf'], @vp['vot']['dpd'], @vp['vot']['dpr'], @vp['vot']['dpo'] = 0,0,0,0,0,0
      @vp['new']['tot'], @vp['new']['dgm'], @vp['new']['dgf'], @vp['new']['dpd'], @vp['new']['dpr'], @vp['new']['dpo'] = 0,0,0,0,0,0
      @vp['new']['vtot'], @vp['ddo']['tot'], @vp['ddo']['vtot'] = 0,0,0  # Tot Registered/Domestic/Domestic+Abs Voters
      @vp['ddo']['va'], @vp['ddo']['vaa'], @vp['ddo']['var'], @vp['ddo']['varl'], @vp['ddo']['varo'] = 0,0,0,0,0
      @vp['ddo']['vp'], @vp['ddo']['vpa'], @vp['ddo']['vpr'], @vp['ddo']['vi'] = 0,0,0,0
      @vp['duu']['tot'], @vp['duu']['vtot'], @vp['duu']['vm'], @vp['duu']['vla'] = 0,0,0,0# Total UOC/U+mil/U+lapsed+Abs Voters
      @vp['duu']['va'], @vp['duu']['vr'], @vp['duu']['vrl'], @vp['duu']['vro'] = 0,0,0,0
      @vp['ddn']['tot'], @vp['ddn']['vtot'] = 0,0  # Tot Registered/Domestic/Domestic+Abs Voters
      @vp['ddn']['va'], @vp['ddn']['vaa'], @vp['ddn']['var'], @vp['ddn']['varl'], @vp['ddn']['varo'] = 0,0,0,0,0
      @vp['ddn']['vp'], @vp['ddn']['vpa'], @vp['ddn']['vpr'], @vp['ddn']['vi'] = 0,0,0,0
      @vp['dun']['tot'], @vp['dun']['vtot'], @vp['dun']['vm'], @vp['dun']['vla'] = 0,0,0,0
      @vp['dun']['va'], @vp['dun']['vr'], @vp['dun']['vrl'], @vp['dun']['vro'] = 0,0,0,0
      @vp['vno']['tot'] = 0
        @vp['vno']['rua'], @vp['vno']['rur'], @vp['vno']['asa'], @vp['vno']['asr'] = 0, 0, 0, 0
      end
      @election.voters.each do |v|
        if VoterRecord.count==0 && nova
          @va['dgm'] += 1 if v.male
          @va['dgf'] += 1 if v.female
          @va['dpd'] += 1 if v.party_democratic
          @va['dpr'] += 1 if v.party_republican
          @va['dpo'] += 1 if v.party_other
          @va['das'] += 1 if v.absentee_status
        end
        @vp['new']['tot'] += 1 if v.new
        if (v.voted)
          @vp['vot']['tot'] += 1
          @vp['vot']['dgm'] += 1 if v.male
          @vp['vot']['dgf'] += 1 if v.female
          @vp['vot']['dpd'] += 1 if v.party_democratic
          @vp['vot']['dpr'] += 1 if v.party_republican
          @vp['vot']['dpo'] += 1 if v.party_other
          if v.new
            @vp['new']['vtot'] += 1
            @vp['new']['dgm'] += 1 if v.male 
            @vp['new']['dgf'] += 1 if v.female
            @vp['new']['dpd'] += 1 if v.party_democratic
            @vp['new']['dpr'] += 1 if v.party_republican
            @vp['new']['dpo'] += 1 if v.party_other
          end
        else
          @vp['vno']['new'] += 1 if v.new
          @vp['vno']['rua'] += 1 if v.vru_approved
          @vp['vno']['rur'] += 1 if v.vru_rejected
          @vp['vno']['asa'] += 1 if v.asr_approved
          @vp['vno']['asr'] += 1 if v.asr_rejected
        end
        if (v.vtype=="UOCAVA")
          if VoterRecord.count==0 && nova
            @va['duu'] += 1
            @va['dum'] += 1 if v.military
            @va['dul'] += 1 if v.absentee_ulapsed
            @va['dua'] += 1 unless v.absentee_ulapsed
          end
          @vp['duu']['vm'] += 1 if v.military
          @vp['dun']['vm'] += 1 if v.military && v.new
          @vp['duu']['tot'] += 1
          @vp['dun']['tot'] += 1 if v.new
          if v.voted
            @vp['duu']['vtot'] += 1
            @vp['duu']['vaa'] += 1 if v.ballot_accepted
            @vp['duu']['var'] += 1 if v.ballot_rejected
            @vp['duu']['varl'] += 1 if v.ballot_rejected_late
            @vp['duu']['varo'] += 1 if v.ballot_rejected_notlate
            @vp['duu']['vla'] += 1 if v.absentee_ulapsed
            if v.new
              @vp['dun']['vtot'] += 1
              @vp['dun']['vaa'] += 1 if v.ballot_accepted
              @vp['dun']['var'] += 1 if v.ballot_rejected
              @vp['dun']['varl'] += 1 if v.ballot_rejected_late
              @vp['dun']['varo'] += 1 if v.ballot_rejected_notlate
              @vp['dun']['vla'] += 1 if v.absentee_ulapsed
            end
          end            
        else
          if VoterRecord.count==0 && nova
            @va['ddo'] += 1
            @va['dda'] += 1 if v.absentee_status
          end
          @vp['ddo']['tot'] += 1
          @vp['ddo']['vtot'] += 1 if v.voted
          if v.new
            @vp['ddn']['tot'] += 1
            @vp['ddn']['vtot'] += 1 if v.voted
          end
          if v.voted_absentee
            @vp['ddo']['va'] += 1
            @vp['ddo']['vaa'] += 1 if v.ballot_accepted
            @vp['ddo']['var'] += 1 if v.ballot_rejected
            @vp['ddo']['varl'] += 1 if v.ballot_rejected_late
            @vp['ddo']['varo'] += 1 if v.ballot_rejected_notlate
            if v.new
              @vp['ddn']['va'] += 1
              @vp['ddn']['vaa'] += 1 if v.ballot_accepted
              @vp['ddn']['var'] += 1 if v.ballot_rejected
              @vp['ddn']['varl'] += 1 if v.ballot_rejected_late
              @vp['ddn']['varo'] += 1 if v.ballot_rejected_notlate
            end
          end
          @vp['ddo']['vi'] += 1 if v.voted_inperson
          @vp['ddn']['vi'] += 1 if v.voted_inperson && v.new
          if v.voted_provisional
            @vp['ddo']['vp'] += 1
            @vp['ddo']['vpa'] += 1 if v.ballot_accepted
            @vp['ddo']['vpr'] += 1 if v.ballot_rejected
            if v.new
              @vp['ddn']['vp'] += 1
              @vp['ddn']['vpa'] += 1 if v.ballot_accepted
              @vp['ddn']['vpr'] += 1 if v.ballot_rejected
            end
          end
        end
      end
      if nova
        @va['duo']   = @va['duu']-@va['dum']
        @va['dum_p'] = self.percent(@va['dum'],@va['duu'])
        @va['duo_p'] = self.percent(@va['duo'],@va['duu'])
        @va['dgm_p'] = self.percent(@va['dgm'],@va['tot'])
        @va['dgf_p'] = self.percent(@va['dgf'],@va['tot'])
        @va['dpd_p'] = self.percent(@va['dpd'],@va['tot'])
        @va['dpr_p'] = self.percent(@va['dpr'],@va['tot'])
        @va['dpo_p'] = self.percent(@va['dpo'],@va['tot'])
      end
      @vp['vno']['new_p'] = self.percent(@vp['vno']['new'],@vp['new']['tot'])
      @vp['vot']['tot_p'] = self.percent(@vp['vot']['tot'],@va['tot'])
      @vp['vot']['dgm_p'] = self.percent(@vp['vot']['dgm'],@vp['vot']['tot'])
      @vp['vot']['dgf_p'] = self.percent(@vp['vot']['dgf'],@vp['vot']['tot'])
      @vp['vot']['dpd_p'] = self.percent(@vp['vot']['dpd'],@vp['vot']['tot'])
      @vp['vot']['dpr_p'] = self.percent(@vp['vot']['dpr'],@vp['vot']['tot'])
      @vp['vot']['dpo_p'] = self.percent(@vp['vot']['dpo'],@vp['vot']['tot'])

      @vp['new']['dgm_p'] = self.percent(@vp['new']['dgm'],@vp['new']['vtot'])
      @vp['new']['dgf_p'] = self.percent(@vp['new']['dgf'],@vp['new']['vtot'])
      @vp['new']['dpd_p'] = self.percent(@vp['new']['dpd'],@vp['new']['vtot'])
      @vp['new']['dpr_p'] = self.percent(@vp['new']['dpr'],@vp['new']['vtot'])
      @vp['new']['dpo_p'] = self.percent(@vp['new']['dpo'],@vp['new']['vtot'])
      @vp['new']['vtot_p'] = self.percent(@vp['new']['vtot']-(@vp['ddn']['vi']+@vp['ddn']['va']+@vp['ddn']['vp']+@vp['dun']['vtot']),@va['tot'])

      @vp['duu']['tot_p'] = self.percent(@vp['duu']['tot'],@va['tot'])
      @vp['duu']['vm_p'] =  self.percent(@vp['duu']['vm'],@va['tot'])
      @vp['duu']['vla_p'] = self.percent(@vp['duu']['vla'],@va['tot'])

      @vp['ddo']['tot_p'] = self.percent(@va['tot']-(@vp['ddo']['vi']+@vp['ddo']['va']+@vp['ddo']['vp']+@vp['duu']['vtot']),@va['tot'])
      @vp['ddo']['vi_p'] = self.percent(@vp['ddo']['vi'],@va['tot'])
      @vp['ddo']['va_p'] =  self.percent(@vp['ddo']['va'],@va['tot'])
      @vp['ddo']['vaa_p'] = self.percent(@vp['ddo']['vaa']+@vp['duu']['vaa'],@va['tot'])
      @vp['ddo']['var_p'] = self.percent(@vp['ddo']['var']+@vp['duu']['var'],@va['tot'])
      @vp['ddo']['vp_p'] =  self.percent(@vp['ddo']['vp'],@va['tot'])
      @vp['ddo']['vpa_p'] = self.percent(@vp['ddo']['vpa'],@va['tot'])
      @vp['ddo']['vpr_p'] = self.percent(@vp['ddo']['vpr'],@va['tot'])
      @vp['ddo']['vpp_p'] = self.percent(@vp['ddo']['vpa'],@vp['ddo']['vp'])


      @vp['ddn']['vi_p'] = self.percent(@vp['ddn']['vi'],@vp['new']['tot'])
      @vp['ddn']['vaa_p'] = self.percent(@vp['ddn']['vaa']+@vp['dun']['vaa'],@vp['new']['tot'])
      @vp['ddn']['var_p'] = self.percent(@vp['ddn']['var']+@vp['dun']['var'],@vp['new']['tot'])
      @vp['ddn']['vpa_p'] = self.percent(@vp['ddn']['vpa'],@vp['new']['tot'])
      @vp['ddn']['vpr_p'] = self.percent(@vp['ddn']['vpr'],@vp['new']['tot'])

      if (@rn==2)
        self.report2()
      elsif (@rn==3 or @rn==4)
        self.report_vu()
      end
    end
  end

  def report_fetch(n,eid=false)
    if eid==false
      unless @ar = AnalyticReport.find{|ar|ar.num==n}
        raise Exception, "No #"+n.to_s+" report found"
      end
    else
      unless @ar = AnalyticReport.find{|ar|ar.election_id==eid&&ar.num==n}
        raise Exception, "No #"+n.to_s+" report found for election id: "+eid
      end
    end
    return @ar, (@ar.data == "" ? @ar.get_data : false)
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

  def report_vu_init()
    @ar, @vu = report_fetch(3,@election.id)
    unless @established && @vu
      @vu = Hash.new {}
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
      @vu['aab']['tota']['abs'] = 0
      @vu['aab']['tota']['abl'] = 0

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
      return false
    end
    return true
  end

  def report_vu()
    unless report_vu_init()
      report_vu_compute()
      @ar.set_data(@vu)
    end
  end

  def report_vu_compute()
    @uvoters = []
    @election.voters.each do |v|
      if v.uocava
        @uvoters.push(v)
      end
    end
    @uvoters.each do |v|
      @vu['aab']['tota']['tot'] += 1
      @vu['aab']['tota']['abs'] += 1 if v.absentee_status
      @vu['aab']['tota']['abl'] += 1 if v.absentee_ulapsed
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
      @vu['aua']['rdow']['tot'] += foundac
      if foundac > 1
        @vu['aua']['rdou']['tot'] += 1
      end
      @vu['aur']['tota']['tot'] += 1 if foundrm > 0
      @vu['aur']['rcom']['tot'] += 1 if foundrc > 0
      @vu['aua']['tota']['tot'] += 1 if foundam > 0
      @vu['aua']['rcom']['tot'] += 1 if foundac > 0
    end

    # @vu['aab']['tota']['tot'] = @vu['aua']['rcom']['tot'] JVC

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

    @vu['aur']['tota']['tot_p'] = self.percent(@vu['aur']['tota']['tot'],@va['duu'])
    @vu['aur']['rcom']['tot_p'] = self.percent(@vu['aur']['rcom']['tot'],@va['duu'])
    @vu['aur']['rcom']['tor_p'] = self.percent(@vu['aur']['rcom']['tot'],@vu['aur']['tota']['tot'])
    @vu['aua']['tota']['tot_p'] = self.percent(@vu['aua']['tota']['tot'],@va['duu'])
    @vu['aua']['rcom']['tot_p'] = self.percent(@vu['aua']['rcom']['tot'],@va['duu'])
    @vu['aua']['rcom']['tor_p'] = self.percent(@vu['aua']['rcom']['tot'],@vu['aur']['tota']['tot'])
    
    @vu['aur']['rrec']['tot_p'] = self.percent(@vu['aur']['rrec']['tot'],@va['duu'])
    @vu['aur']['rapp']['tot_p'] = self.percent_parens(@vu['aur']['rapp']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rrej']['tot_p'] = self.percent_parens(@vu['aur']['rrej']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rlos']['tot_p'] = self.percent_forms(@vu['aur']['rlos']['tot'],@vu['aur']['rgen']['tot'])

    @vu['arr']['rrec']['tot_p'] = self.percent(@vu['arr']['rrec']['tot'],@va['duu'])
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
    @vu['arr']['rnew']['tot_p'] = self.percent(@vu['arr']['rapp']['tot'],@va['tot'])

    @vu['aru']['rrec']['tot_p'] = self.percent(@vu['aru']['rrec']['tot'],@va['duu'])
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

    @vu['aas']['rrec']['tot_p'] = self.percent(@vu['aas']['rrec']['tot'],@va['duu'])
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

    @vu['aab']['rrec']['tot_p'] = self.percent(@vu['aab']['rrec']['tot'],@va['duu'])
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
