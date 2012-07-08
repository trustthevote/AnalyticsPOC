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
    self.report()
    respond_to do |f|
      f.html { render '/analytic_reports/report'+@rn.to_s }
      f.pdf  { render layout: false }
    end
  end

# Legend Voters All @va[key]
#   
# tot Total
# dda Demographic Domestic Absentee
# ddo Demographic Domestic 
# dgf Demographic Gender Female
# dgm Demographic Gender Male
# dpd Demographic Party Democratic
# dpo Demographic Party 3rd
# dpr Demographic Party Republican
# dua Demographic UOCAVA Absentee
# dul Demographic UOCAVA Lapsed
# dum Demographic UOCAVA Military
# duo Demographic UOCAVA Overseas
# duu Demographic UOCAVA
# dnw New
# ngf New Gender Female
# ngm New Gender Male
# npd New Party Democratic
# npo New Party 3rd
# npr New Party Republican

  def report()
    nova = false
    unless @va = voter_record_report_fetch(@election)
      if VoterRecord.count > 0 #JVC try to find existing saved report
        @va = voter_record_report_init()
        VoterRecord.all.each do |vr|
          voter_record_report_update(@va, vr)
        end
        voter_record_report_finalize(@va)
        voter_record_report_save(@va, @election)
      else
        unless @va = voter_record_reporx_fetch(@election)
          nova = true
          @va = voter_record_report_init()
        end
      end
    end
    case @rn
    when 1,2
      @vp = voter_participating_report_fetch(@election)
      return if @vp && !nova
      @vp = voter_participating_report_init()
      voter_participating_report_compute(nova)
      voter_record_reporx_save(@va, @election) if nova
      voter_participating_report_save(@vp, @election)
    when 3,4
      @vu = voter_uocava_report_fetch(@election)
      return if @vu && !nova
      @vu = voter_uocava_report_init()
      voter_uocava_report_compute(nova)
      voter_record_reporx_save(@va, @election) if nova
      voter_uocava_report_save(@vu, @election)
    else
      raise Exception, "Unknown report number: "+@rn
    end
  end

  def voter_participating_report_init()
    @vp = Hash.new {}
    %w(all nra rur rua asr asa).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot don dgm dgf dpd dpr dpo vno vra vpa vaa vpr varl varo).each do |k2|
        @vp[k1][k2] = 0
      end
    end
    @vp['vno'] = Hash.new {}
    %w(tot new rra rua rur asa asr).each{|k|@vp['vno'][k]=0}
    @vp['vno']['tot_p'] = "0%"
    @vp['vno']['new_p'] = "0%"
    %w(vot new).each do |k1|
      @vp[k1] = Hash.new {}
      %w(tot dgm dgf dpd dpr dpo vaa var vtot).each do |k2|
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
      @vp['ddn'][kp+'_p'] = "0%" unless kp=='vpp'
      @vp['ddo'][kp+'_p'] = "0%"
    end
    return @vp
  end

  def voter_participating_report_compute(nova)
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
      if (v.voted)
        report_demographic(v, @vp['vot'])
        report_demographic(v, @vp['new']) if v.new
        @vp['new']['vtot'] += 1 if v.new
      else
        @vp['new']['tot'] += 1 if v.new
        @vp['vno']['new'] += 1 if v.new
        @vp['vno']['rra'] += 1 if v.vrr_approved
        @vp['vno']['rua'] += 1 if v.vru_approved
        @vp['vno']['rur'] += 1 if v.vru_rejected
        @vp['vno']['asa'] += 1 if v.asr_approved
        @vp['vno']['asr'] += 1 if v.asr_rejected
      end
      if (v.vtype=="UOCAVA")
        @vp['duu']['tot'] += 1
        @vp['dun']['tot'] += 1 if v.new
        @vp['duu']['vm']  += 1 if v.military
        @vp['dun']['vm']  += 1 if v.military && v.new
        if v.voted
          @vp['duu']['vtot'] += 1
          report_abs_balloting(v, @vp['duu'])
          @vp['duu']['vla'] += 1 if v.absentee_ulapsed
          if v.new
            @vp['dun']['vtot'] += 1
            report_abs_balloting(v, @vp['dun'])
            @vp['dun']['vla'] += 1 if v.absentee_ulapsed
          end
        end            
      else
        @vp['ddo']['tot'] += 1
        @vp['ddo']['vtot'] += 1 if v.voted
        if v.new
          @vp['ddn']['tot'] += 1
          @vp['ddn']['vtot'] += 1 if v.voted
        end
        if v.voted_absentee
          report_abs_balloting(v, @vp['ddo'], true)
          report_abs_balloting(v, @vp['ddn'], true) if v.new
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
      voter_record_report_update(@va, v) if nova
    end
    voter_record_report_finalize(@va) if nova

    @vp['vno']['tot'] = @va['tot']-@vp['vot']['tot']
    @vp['vno']['tot_p'] = percent(@vp['vno']['tot'],@va['tot'])
    @vp['vno']['new_p'] = percent(@vp['vno']['new'],@vp['new']['tot'])

    @vp['vot']['vaa'] = @vp['ddo']['vaa']+@vp['duu']['vaa']
    @vp['vot']['var'] = @vp['ddo']['var']+@vp['duu']['var']
    report_percentage(@vp['vot'], %w(vaa var tot), @va['tot'])

    @vp['new']['vaa'] = @vp['ddn']['vaa']+@vp['dun']['vaa']
    @vp['new']['var'] = @vp['ddn']['var']+@vp['dun']['var']
    report_percentage(@vp['new'], %w(vaa var), @va['tot'])

    report_percentage(@vp['vot'], %w(dgm dgf dpd dpr dpo), @vp['vot']['tot'])
    report_percentage(@vp['new'], %w(dgm dgf dpd dpr dpo), @vp['new']['vtot'])
    report_percentage(@vp['duu'], %w(tot vm vla), @va['tot'])

    @vp['ddo']['vpp_p'] = percent(@vp['ddo']['vpa'],@vp['ddo']['vp'])

    report_percentage(@vp['ddo'], %w(vi va vp vpa vpr), @va['tot'])
    report_percentage(@vp['ddn'], %w(vi vpa vpr), @vp['new']['tot'])
    
    %w(all nra rur rua asr asa).each do |k|
      report_percentage(@vp[k], %w(dgm dgf dpd dpr dpo don), @vp[k]['tot'])
      @vp[k]['dox_p'] = percent(@vp[k]['tot']-@vp[k]['don'],@vp[k]['tot'])
    end
  end

  def report_abs_balloting(v, vhash, vaflag=false)
    vhash['va'] += 1 if vaflag
    vhash['vaa'] += 1 if v.ballot_accepted
    vhash['var'] += 1 if v.ballot_rejected
    vhash['varl'] += 1 if v.ballot_rejected_late
    vhash['varo'] += 1 if v.ballot_rejected_notlate
  end

  def report2_data(v,vhash)
    vhash['don'] += 1 if v.vonline
    self.report_demographic(v, vhash)
    if (!v.voted)
      vhash['vno'] += 1
    elsif (!v.vote_reject)
      vhash['vra'] += 1 if (v.vote_form=~/Regular/)
      vhash['vpa'] += 1 if (v.vote_form=~/Provisional/)
      vhash['vaa'] += 1 if (v.vote_form=~/Absentee/)
    else
      vhash['vpr'] += 1 if (v.vote_form=~/Provisional/)
      vhash['varl'] += 1 if (v.vote_form=~/Absentee/ && v.ballot_rejected_late)
      vhash['varo'] += 1 if (v.vote_form=~/Absentee/ && v.ballot_rejected_notlate)
    end
  end

  def voter_uocava_report_init()
    @vu = Hash.new {}
    %w(aab aas arr aru).each do |k1|
      @vu[k1] = Hash.new {}
      %w(rapp rrec rrej drej).each do |k2|
        @vu[k1][k2] = Hash.new {}
        %w(dum duo tot).each do |k3|
          @vu[k1][k2][k3] = 0  
          @vu[k1][k2][k3+'_p'] = "0%"
        end
      end
      %w(rrej drej).each do |k2|
        %w(dgf dgm dpd dpr dpo).each do |k3|
          @vu[k1][k2][k3] = 0  
          @vu[k1][k2][k3+'_p'] = "0%"
        end
      end
      k2 = 'rrej'
      %w(dla dlm).each do |k3|
        @vu[k1][k2][k3] = 0
      end
      %w(rgen rlos).each do |k2|
        @vu[k1][k2] = Hash.new {}
        @vu[k1][k2]['tot'] = 0
      end
      @vu[k1]['rlos']['tot_p'] = "0%"
    end
    @vu['arr']['rnew'] = Hash.new {}
    @vu['arr']['rnew']['tot_p'] = "0%"
    
    @vu['aab']['tota'] = Hash.new {}
    %w(tot abs abl).each do |k3|
      @vu['aab']['tota'][k3] = 0
    end
    
    @vu['aua'] = Hash.new {}
    %w(rcom tota rdou rdow).each do |k2|
      @vu['aua'][k2] = Hash.new {}
      @vu['aua'][k2]['tot'] = 0
    end
    @vu['aua']['rcom']['tot_p'] = "0%"
    @vu['aua']['rcom']['tor_p'] = "0%"
    
    @vu['aur'] = Hash.new {}
    %w(rapp tota rcom rgen rlos rrec rrej).each do |k2|
      @vu['aur'][k2] = Hash.new {}
      @vu['aur'][k2]['tot'] = 0
      @vu['aur'][k2]['tot_p'] = "0%" unless %w(tota rgen).include?(k2)
    end
    @vu['aur']['rcom']['tor_p'] = "0%"
    return @vu
  end

  def voter_uocava_domestic_form(vtr, v, k1)
    if (vtr.action=~/reject/)
      report_demographic(v, @vu[k1]['drej'])
    end
  end

  def voter_uocava_report_form(vtr, v, k1)
    if (vtr.action=~/complete/)
      @vu[k1]['rgen']['tot'] +=  1
    elsif (vtr.action=~/match/ || vtr.action=~/transcribe/)
      @vu[k1]['rrec']['tot'] += 1
      @vu[k1]['rrec']['dum'] += 1 if v.military
    elsif (vtr.action=~/approve/)
      @vu[k1]['rapp']['tot'] += 1
      @vu[k1]['rapp']['dum'] += 1 if v.military
    elsif (vtr.action=~/reject/)
      @vu[k1]['rrej']['tot'] += 1
      @vu[k1]['rrej']['dum'] += 1 if v.military
      @vu[k1]['rrej']['dgm'] += 1 if v.male
      @vu[k1]['rrej']['dgf'] += 1 if v.female
      @vu[k1]['rrej']['dpd'] += 1 if v.party_democratic
      @vu[k1]['rrej']['dpr'] += 1 if v.party_republican
      if (vtr.note =~ /late/)
        @vu[k1]['rrej']['dla'] += 1
        @vu[k1]['rrej']['dlm'] += 1 if v.military
      end
    end
  end

  def voter_uocava_report_compute(nova)
    @uvoters = []
    @election.voters.each do |v|
      if v.uocava
        @vu['aab']['tota']['tot'] += 1
        @vu['aab']['tota']['abs'] += 1 if v.absentee_status
        @vu['aab']['tota']['abl'] += 1 if v.absentee_ulapsed
        foundrm, foundrc, foundam, foundac = 0, 0, 0, 0
        v.vtrs.each do |vtr|
          if (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
            foundrm += 1
            foundrc += 1 if vtr.action=~/complete/
            @vu['aur']['rrec']['tot'] += 1 if vtr.action=~/match/ || vtr.action=~/transcribe/
            @vu['aur']['rapp']['tot'] += 1 if vtr.action=~/approve/
            @vu['aur']['rrej']['tot'] += 1 if vtr.action=~/reject/
            if (vtr.form =~ /Voter Registration/)
              voter_uocava_report_form(vtr, v, 'arr')
            elsif (vtr.form =~ /Voter Record Update/)
              voter_uocava_report_form(vtr, v, 'aru')
            elsif (vtr.form =~ /Absentee Request/)
              voter_uocava_report_form(vtr, v, 'aas')
            end
          elsif (vtr.form =~ /Absentee Ballot/)
            foundam += 1
            foundac += 1 if vtr.action=~/complete/
            voter_uocava_report_form(vtr, v, 'aab')
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
      else
        v.vtrs.each do |vtr|
          if (vtr.form =~ /Voter Registration/)
            voter_uocava_domestic_form(vtr, v, 'arr')
          elsif (vtr.form =~ /Voter Record Update/)
            voter_uocava_domestic_form(vtr, v, 'aru')
          elsif (vtr.form =~ /Absentee Request/)
            voter_uocava_domestic_form(vtr, v, 'aas')
          elsif (vtr.form =~ /Absentee Ballot/)
            voter_uocava_domestic_form(vtr, v, 'aab')
          end
        end
      end
      voter_record_report_update(@va, v) if nova
    end
    voter_record_report_finalize(@va) if nova

    report_percentage(@vu['arr']['rrej'], %w(dgm dgf dpd dpr), @va['duu'])
    report_percentage(@vu['aru']['rrej'], %w(dgm dgf dpd dpr), @va['duu'])
    report_percentage(@vu['aas']['rrej'], %w(dgm dgf dpd dpr), @va['duu'])
    report_percentage(@vu['aab']['rrej'], %w(dgm dgf dpd dpr), @va['duu'])

    report_percentage(@vu['arr']['drej'], %w(dgm dgf dpd dpr), @va['ddo'])
    report_percentage(@vu['aru']['drej'], %w(dgm dgf dpd dpr), @va['ddo'])
    report_percentage(@vu['aas']['drej'], %w(dgm dgf dpd dpr), @va['ddo'])
    report_percentage(@vu['aab']['drej'], %w(dgm dgf dpd dpr), @va['ddo'])

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

    @vu['aur']['tota']['tot_p'] = percent(@vu['aur']['tota']['tot'],@va['duu'])
    @vu['aur']['rcom']['tot_p'] = percent(@vu['aur']['rcom']['tot'],@va['duu'])
    @vu['aur']['rcom']['tor_p'] = percent(@vu['aur']['rcom']['tot'],@vu['aur']['tota']['tot'])
    @vu['aua']['tota']['tot_p'] = percent(@vu['aua']['tota']['tot'],@va['duu'])
    @vu['aua']['rcom']['tot_p'] = percent(@vu['aua']['rcom']['tot'],@va['duu'])
    @vu['aua']['rcom']['tor_p'] = percent(@vu['aua']['rcom']['tot'],@vu['aur']['tota']['tot'])
    
    @vu['aur']['rrec']['tot_p'] = percent(@vu['aur']['rrec']['tot'],@va['duu'])
    @vu['aur']['rapp']['tot_p'] = percent_parens(@vu['aur']['rapp']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rrej']['tot_p'] = percent_parens(@vu['aur']['rrej']['tot'],@vu['aur']['rrec']['tot'])
    @vu['aur']['rlos']['tot_p'] = percent_forms(@vu['aur']['rlos']['tot'],@vu['aur']['rgen']['tot'])

    @vu['arr']['rrec']['tot_p'] = percent(@vu['arr']['rrec']['tot'],@va['duu'])
    @vu['arr']['rrec']['dum_p'] = percent(@vu['arr']['rrec']['dum'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rrec']['duo_p'] = percent(@vu['arr']['rrec']['duo'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rapp']['duo_p'] = percent(@vu['arr']['rapp']['duo'],@vu['arr']['rapp']['tot'])
    @vu['arr']['rapp']['dum_p'] = percent(@vu['arr']['rapp']['dum'],@vu['arr']['rapp']['tot'])
    @vu['arr']['rrej']['duo_p'] = percent(@vu['arr']['rrej']['duo'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rrej']['dum_p'] = percent(@vu['arr']['rrej']['dum'],@vu['arr']['rrej']['tot'])
    @vu['arr']['rapp']['tot_p'] = percent_parens(@vu['arr']['rapp']['tot'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rrej']['tot_p'] = percent_parens(@vu['arr']['rrej']['tot'],@vu['arr']['rrec']['tot'])
    @vu['arr']['rlos']['tot_p'] = percent_forms(@vu['arr']['rlos']['tot'],@vu['arr']['rgen']['tot'])
    @vu['arr']['rnew']['tot_p'] = percent(@vu['arr']['rapp']['tot'],@va['tot'])

    @vu['aru']['rrec']['tot_p'] = percent(@vu['aru']['rrec']['tot'],@va['duu'])
    @vu['aru']['rrec']['dum_p'] = percent(@vu['aru']['rrec']['dum'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rrec']['duo_p'] = percent(@vu['aru']['rrec']['duo'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rapp']['duo_p'] = percent(@vu['aru']['rapp']['duo'],@vu['aru']['rapp']['tot'])
    @vu['aru']['rapp']['dum_p'] = percent(@vu['aru']['rapp']['dum'],@vu['aru']['rapp']['tot'])
    @vu['aru']['rrej']['duo_p'] = percent(@vu['aru']['rrej']['duo'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rrej']['dum_p'] = percent(@vu['aru']['rrej']['dum'],@vu['aru']['rrej']['tot'])
    @vu['aru']['rapp']['tot_p'] = percent_parens(@vu['aru']['rapp']['tot'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rrej']['tot_p'] = percent_parens(@vu['aru']['rrej']['tot'],@vu['aru']['rrec']['tot'])
    @vu['aru']['rlos']['tot_p'] = percent_forms(@vu['aru']['rlos']['tot'],@vu['aru']['rgen']['tot'])

    @vu['aas']['rrec']['tot_p'] = percent(@vu['aas']['rrec']['tot'],@va['duu'])
    @vu['aas']['rrec']['dum_p'] = percent(@vu['aas']['rrec']['dum'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rrec']['duo_p'] = percent(@vu['aas']['rrec']['duo'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rapp']['duo_p'] = percent(@vu['aas']['rapp']['duo'],@vu['aas']['rapp']['tot'])
    @vu['aas']['rapp']['dum_p'] = percent(@vu['aas']['rapp']['dum'],@vu['aas']['rapp']['tot'])
    @vu['aas']['rrej']['duo_p'] = percent(@vu['aas']['rrej']['duo'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rrej']['dum_p'] = percent(@vu['aas']['rrej']['dum'],@vu['aas']['rrej']['tot'])
    @vu['aas']['rapp']['tot_p'] = percent_parens(@vu['aas']['rapp']['tot'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rrej']['tot_p'] = percent_parens(@vu['aas']['rrej']['tot'],@vu['aas']['rrec']['tot'])
    @vu['aas']['rlos']['tot_p'] = percent_forms(@vu['aas']['rlos']['tot'],@vu['aas']['rgen']['tot'])

    @vu['aab']['rrec']['tot_p'] = percent(@vu['aab']['rrec']['tot'],@va['duu'])
    @vu['aab']['rrec']['dum_p'] = percent(@vu['aab']['rrec']['dum'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rrec']['duo_p'] = percent(@vu['aab']['rrec']['duo'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rapp']['duo_p'] = percent(@vu['aab']['rapp']['duo'],@vu['aab']['rapp']['tot'])
    @vu['aab']['rapp']['dum_p'] = percent(@vu['aab']['rapp']['dum'],@vu['aab']['rapp']['tot'])
    @vu['aab']['rrej']['duo_p'] = percent(@vu['aab']['rrej']['duo'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rrej']['dum_p'] = percent(@vu['aab']['rrej']['dum'],@vu['aab']['rrej']['tot'])
    @vu['aab']['rapp']['tot_p'] = percent_parens(@vu['aab']['rapp']['tot'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rrej']['tot_p'] = percent_parens(@vu['aab']['rrej']['tot'],@vu['aab']['rrec']['tot'])
    @vu['aab']['rlos']['tot_p'] = percent_forms(@vu['aab']['rlos']['tot'],@vu['aab']['rgen']['tot'])
    return @vu
  end

  # DELETE /analytic_reports/1
  def destroy
    @analytic_report = AnalyticReport.find(params[:id])
    @analytic_report.destroy

    respond_to do |format|
      format.html { redirect_to '/analytic_reports/index' }
    end
  end

  # RESET /analytic_reports/reset?id=N
  def reset
    @analytic_report = AnalyticReport.find(params[:id])
    @analytic_report.data = ""
    @analytic_report.save

    respond_to do |format|
      format.html { redirect_to '/analytic_reports/index' }
    end
  end

end
