class AnalyticReportsController < ApplicationController
  before_filter :current_user!

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
          voter_record_report_update(@va, vr, @election)
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
    when 5
      # @vf = voter_report_fetch(5, @election)            
      # return if @vf && !nova
      @vf = voter_fvap_report_init(@election)
      voter_fvap_report_compute(nova)
      # voter_record_reporx_save(@va, @election) if nova
      voter_report_save(@vf, 5, @election.id)
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
      if (v.votes>0)
        report_demographic(v, @vp['vot'])
        report_demographic(v, @vp['new']) if v.new?
        @vp['new']['vtot'] += 1 if v.new?
      else
        @vp['new']['tot'] += 1 if v.new?
        @vp['vno']['new'] += 1 if v.new?
        @vp['vno']['rra'] += 1 if v.vrr_approved
        @vp['vno']['rua'] += 1 if v.vru_approved
        @vp['vno']['rur'] += 1 if v.vru_rejected
        @vp['vno']['asa'] += 1 if v.asr_approved
        @vp['vno']['asr'] += 1 if v.asr_rejected
      end
      if (v.uocava?)
        @vp['duu']['tot'] += 1
        @vp['dun']['tot'] += 1 if v.new?
        @vp['duu']['vm']  += 1 if v.military?
        @vp['dun']['vm']  += 1 if v.military? && v.new?
        if v.votes>0
          @vp['duu']['vtot'] += 1
          report_abs_balloting(v, @vp['duu'])
          @vp['duu']['vla'] += 1 if v.absentee_ulapsed?
          if v.new?
            @vp['dun']['vtot'] += 1
            report_abs_balloting(v, @vp['dun'])
            @vp['dun']['vla'] += 1 if v.absentee_ulapsed?
          end
        end            
      else
        @vp['ddo']['tot'] += 1
        @vp['ddo']['vtot'] += 1 if v.votes>0
        if v.new?
          @vp['ddn']['tot'] += 1
          @vp['ddn']['vtot'] += 1 if v.votes>0
        end
        if v.voted_absentee
          report_abs_balloting(v, @vp['ddo'], true)
          report_abs_balloting(v, @vp['ddn'], true) if v.new?
        end
        @vp['ddo']['vi'] += 1 if v.voted_inperson
        @vp['ddn']['vi'] += 1 if v.voted_inperson && v.new?
        if v.voted_provisional
          @vp['ddo']['vp'] += 1
          @vp['ddo']['vpa'] += 1 if v.ballot_accepted
          @vp['ddo']['vpr'] += 1 if v.ballot_rejected
          if v.new?
            @vp['ddn']['vp'] += 1
            @vp['ddn']['vpa'] += 1 if v.ballot_accepted
            @vp['ddn']['vpr'] += 1 if v.ballot_rejected
          end
        end
      end
      voter_record_report_update(@va, v, @election) if nova
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
    if (v.votes==0)
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

#    vf[count]
# 01     [jurisdiction] {derived from VA} (UOD)
# 19     [registered] {form=VR,action=approve} (UOD)
# 25     [online] (UOD) ?? 19 ??
# 27     [multipleABdownload] (UOD)
#      [complete]
# 26     [formAB] (UOD)
# 20     [formVR] {date>election_start_day} (UOD)
#      [receive]
# 04     [formVRpre45] {formNote!=FPCA} (PFEO)
# 05     [formVRpost45] {formNote!=FPCA} (PFEO)
# 22     [formAR] (UOD)
# 06     [formARpre45] {formNote!=FPCA} (PFEO)
# 07     [formARpost45] {formNote!=FPCA} (PFEO)
# 13     [formAB] (PFE)
# 15     [formABpreBR] (TOT)
# 16     [formABformNoteFWAB] (TOT)
# 18     [formABformNoteFWABpreBR] (TOT)
# 09     [formNoteFPCApostVR] (TOT)
# 02     [formNoteFPCApre45] (PFEO)
# 03     [formNoteFPCApost45] (PFEO)
# 10     [formNoteNotFPCApostVR] (TOT)
#      [reject]
# 21     [formVR] (UOD)
# 17     [formAB] {formNote==FWAB} (TOT)
# 08     [formNoteFPCA] {notes==rejectIncomplete} (TOT)
# 11     [formNoteNotFPCA] {notes==rejectIncomplete} (TOT)
#      [returnedUndelivered]
# 14     [formAB] (TOT)
#      [sentToVoter]
# 12     [formAB] (PFE)
#   
#    UOD: [total] [military] [overseas] [domestic]
#    PFEO: [total] [postal] [fax] [email] [online]
#    TOT: [total]

  def voter_fvap_report_init(election)
    @vf = Hash.new {}
    @vf['dates'] = Hash.new {}
    @vf['dates']['end'] = election.voter_end_day.to_s
    @vf['dates']['pre45'] = (election.voter_end_day-45).to_s
    @vf['dates']['preVR'] = (election.voter_end_day-46).to_s
    @vf['dates']['preBR'] = (election.voter_end_day-43).to_s
    @vf['dates']['start'] = election.voter_start_day.to_s
    k1s = %w(count complete receive reject returnedUndelivered sentToVoter)
    k1s.each do |k1|
      @vf[k1] = Hash.new {}
    end
    voter_fvap_uod_init(@vf,'count',%w(jurisdiction registered online multipleABdownload))
    voter_fvap_uod_init(@vf,'complete',%w(formAB formVR))
    voter_fvap_uod_init(@vf,'receive',%w(formAR formABpreBR formABformNoteFWAB formABformNoteFWABpreBR formNoteFPCApostVR formNoteNotFPCApostVR))
    voter_fvap_uod_init(@vf,'reject',%w(formVR formAB formNoteFPCA formNoteNotFPCA))
    voter_fvap_uod_init(@vf,'returnedUndelivered',%w(formAB))
    voter_fvap_pfeo_init(@vf,'receive',%w(formVRpre45 formVRpost45 formARpre45 formARpost45 formAB formNoteFPCApre45 formNoteFPCApost45))
    voter_fvap_pfeo_init(@vf,'sentToVoter',%w(formAB))
    return @vf
  end

  def voter_fvap_uod_init (hash, k1, k2s)
    k2s.each do |k2|
      @vf[k1][k2] = Hash.new {}
      %w(total military overseas domestic).each do |k3|
        @vf[k1][k2][k3] = 0
      end
    end
  end
  
  def voter_fvap_pfeo_init (hash, k1, k2s)
    k2s.each do |k2|
      @vf[k1][k2] = Hash.new {}
      %w(total postal fax email online).each do |k3|
        @vf[k1][k2][k3] = Hash.new {}
        %w(total military overseas domestic).each do |k4|
          @vf[k1][k2][k3][k4] = 0
        end
      end
    end
  end

  def fvap_uod(v)
    if v.military?
      return 1, 0, 0, 1
    elsif v.overseas?
      return 0, 1, 0, 1
    else
      return 0, 0, 1, 1
    end
  end

  def fvap_update_uod(hash,u,o,d,t)
    hash['military'] += u
    hash['overseas'] += o
    hash['domestic'] += d
    hash['total'] += t
  end

  def fvap_valid_pfeo_sent?(notes)
    case notes
    when 'postalSent'
    then
      return 'postal'
    when 'faxSent'
    then
      return 'fax'
    when 'emailSent'
    then
      return 'email'
    else
      return false
    end
  end
  
  def fvap_valid_pfeo_received?(notes)
    case notes
    when 'postalReceived'
    then
      return 'postal'
    when 'faxReceived'
    then
      return 'fax'
    when 'personalReceived'
    then
      return false
    else
      return false
    end
  end
  
  def voter_fvap_report_compute(nova)
    @election.voters.each do |v|
      (u,o,d,t) = fvap_uod(v)
      if v.vonline
        fvap_update_uod(@vf['count']['online'],u,o,d,t)
      end
      ab_downloads = 0
      v.vtrs.each do |vtr|
        case vtr.action
        when 'complete'
        then
          if vtr.absentee_ballot_form?
            ab_downloads += 1
            fvap_update_uod(@vf['complete']['formAB'],u,o,d,t)              
            fvap_update_uod(@vf['sentToVoter']['formAB']['online'],u,o,d,t)
          elsif vtr.voter_registration_form?
            if vtr.datime >= @election.voter_start_day
              fvap_update_uod(@vf['complete']['formVR'],u,o,d,t)              
            end
          end
        when 'receive'
        then
          if pfeo = fvap_valid_pfeo_received?(vtr.note)
            if vtr.fpca_form_note?
              if vtr.datime <= @vf['dates']['pre45']
                fvap_update_uod(@vf['receive']['formNoteFPCApre45'][pfeo],u,o,d,t)
              else
                fvap_update_uod(@vf['receive']['formNoteFPCApost45'][pfeo],u,o,d,t)
              end
            else
              if vtr.voter_registration_form?
                if vtr.datime <= @vf['dates']['pre45']
                  fvap_update_uod(@vf['receive']['formVRpre45'][pfeo],u,o,d,t)
                else
                  fvap_update_uod(@vf['receive']['formVRpost45'][pfeo],u,o,d,t)
                end
              elsif vtr.absentee_request_form?
                if vtr.datime <= @vf['dates']['pre45']
                  fvap_update_uod(@vf['receive']['formARpre45'][pfeo],u,o,d,t)
                else
                  fvap_update_uod(@vf['receive']['formARpost45'][pfeo],u,o,d,t)
                end
              elsif vtr.absentee_ballot_form?
                fvap_update_uod(@vf['receive']['formAB'][pfeo],u,o,d,t)                       end
            end
          end
          if vtr.absentee_request_form?
            fvap_update_uod(@vf['receive']['formAR'],u,o,d,t)
          elsif vtr.absentee_ballot_form?
            if vtr.datime <= @vf['dates']['preBR']
              fvap_update_uod(@vf['receive']['formABpreBR'],u,o,d,t)
            end
            if vtr.fwab_form_note?
              fvap_update_uod(@vf['receive']['formABformNoteFWAB'],u,o,d,t)
              if vtr.datime <= @vf['dates']['preBR'] 
                fvap_update_uod(@vf['receive']['formABformNoteFWABpreBR'],u,o,d,t)
              end
            end
          end
          if vtr.datime > @vf['dates']['preVR']
            if vtr.fpca_form_note?
              fvap_update_uod(@vf['receive']['formNoteFPCApostVR'],u,o,d,t)
            else
              fvap_update_uod(@vf['receive']['formNoteNotFPCApostVR'],u,o,d,t)
            end
          end
        when 'approve'
        then
          if vtr.voter_registration_form?
            if vtr.datime <= @vf['dates']['preVR']
              fvap_update_uod(@vf['count']['registered'],u,o,d,t)
            end
          end
        when 'reject'
        then
          if vtr.voter_registration_form?
            fvap_update_uod(@vf['reject']['formVR'],u,o,d,t)
          elsif vtr.absentee_ballot_form? and vtr.fwab_form_note?
            fvap_update_uod(@vf['reject']['formAB'],u,o,d,t)
          end
          if vtr.reject_incomplete_notes?
            if vtr.fpca_form_note?
              fvap_update_uod(@vf['reject']['formNoteFPCA'],u,o,d,t)
            else
              fvap_update_uod(@vf['reject']['formNoteNotFPCA'],u,o,d,t)
            end
          end
        when 'returnedUndelivered'
        then
          if vtr.absentee_ballot_form?
            fvap_update_uod(@vf['returnedUndelivered']['formAB'],u,o,d,t)
          end
        when 'sentToVoter'
        then
          if vtr.absentee_ballot_form?
            if pfeo = fvap_valid_pfeo_sent?(vtr.note)
              fvap_update_uod(@vf['sentToVoter']['formAB'][pfeo],u,o,d,t)
            end
          end
        end
      end
      if ab_downloads > 1
        fvap_update_uod(@vf['count']['multipleABdownload'],u,o,d,t)
      end
      voter_record_report_update(@va, v, @election) if nova
    end
    voter_record_report_finalize(@va) if nova
    fdates = @vf['dates']
    pre45date = fdates['pre45'].to_date
    preVRdate = fdates['preVR'].to_date
    preBRdate = fdates['preBR'].to_date
    @vfdates = pre45date.to_s + " " + preVRdate.to_s + " " + preBRdate.to_s
    @vf['count']['jurisdiction']['total'] =    @va['tot']
    @vf['count']['jurisdiction']['military'] = @va['dum']
    @vf['count']['jurisdiction']['overseas'] = @va['duo']
    @vf['count']['jurisdiction']['domestic'] = @va['ddo']
    @r5qs = [["Header","Normal","Virginia,Uniformed Service,Overseas Civilians,Non UOCAVA,Total"],
             ["UOD","count","jurisdiction","1.","How many registered voters in your jurisdiction as of the voter registration deadline for this election?"],
          ["PFEO","receive","formNoteFPCApre45","2.","How many FPCAs did you receive before the 45 day deadline by the following modes of submission?"],
          ["PFEO","receive","formNoteFPCApost45","3.","How many FPCAs did you receive after the 45 day deadline by the following modes of submission?"],
          ["PFEO","receive","formVRpre45","4.","How many non-FPCA registrations did you receive before the 45 day deadline by the following modes of submission?"],
          ["PFEO","receive","formVRpost45","5.","How many  non-FPCA registrations did you receive after the 45 day deadline by the following modes of submission?"],
          ["PFEO","receive","formARpre45","6.","How many  non-FPCA ballot requests did you receive before the 45 day deadline by the following modes of submission?"],
          ["PFEO","receive","formARpost45","7.","How many  non-FPCA ballot requests did you receive after the 45 day deadline by the following modes of submission?"],
          ["UOD","reject","formNoteFPCA","8.","How many FPCAs were were submitted as incomplete?"],
          ["UOD","receive","formNoteFPCApostVR","9.","How many FPCAs were received after your jurisdiction\'s voter registration or absentee ballot request deadline?"],
          ["UOD","receive","formNoteNotFPCApostVR","10.","How many non FPCAs were received after your jurisdiction\'s voter registration or absentee ballot request deadline?"],
          ["UOD","reject","formNoteNotFPCA","11.","How many non FPCAs were submitted as incomplete?"],
          ["PFEO","sentToVoter","formAB","12.","How many  absentee ballots were transmitted using the following modes of transmission:"],
          ["PFE","receive","formAB","13.","How many absentee  ballots were returned and by what means of transmission ?"],
          ["UOD","returnedUndelivered","formAB","14.","How many absentee ballots were returned as undeliverable?"],
          ["UOD","receive","formABpreBR","15.","How many absentee ballots they were received after the ballot receipt deadline?"],
          ["UOD","receive","formABformNoteFWAB","16.","How many FWABs were cast?"],
          ["UOD","reject","formAB","17.","How many FWABSs were rejected?"],
          ["N/A","17A.","How many FWABs were replaced by a State ballot?"],
          ["UOD","receive","formABformNoteFWABpreBR","18.","How many FWABs were received after the ballot receipt deadline?"],

          ["Header","Online Voter Registration","Virginia,Uniformed Service Member,Overseas Civilians,Non UOCAVA,Total"],
          ["UOD","count","registered","1.","Number of voters registered before."],
          ["UOD","complete","formVR","2.","Number of new registration requests since."],
          ["UOD","reject","formVR","3.","Number of registration requests rejected."],
          
          ["Header","Online Absentee Ballot Application","Virginia,Uniformed Service Member,Overseas Civilians,Non UOCAVA,Total"],
          ["UOD","receive","formAR","1.","Number of ballot applications received."],
          ["N/A","2.","Number of application from domestic IP addresses"],
          ["N/A","3.","Number of application from foreign IP addresses"],

          ["Header","Online Absentee Ballot Delivery","Virginia,Uniformed Service Member,Overseas Civilians,Non UOCAVA,Total"],
          ["UOD","count","online","1.","Number of people that accessed the system."],
          ["UOD","complete","formAB","2.","Number of ballots downloaded."],
          ["UOD","count","multipleABdownload","3.","Number of ballots downloaded multiple times from the same user."],
          ["N/A","4.","Number of ballots downloaded from domestic IP addresses."],
          ["N/A","5.","Number of ballots downloaded from foreign IP addresses."]]
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
      @vu[k1]['rrec']['dum'] += 1 if v.military?
    elsif (vtr.action=~/approve/)
      @vu[k1]['rapp']['tot'] += 1
      @vu[k1]['rapp']['dum'] += 1 if v.military?
    elsif (vtr.action=~/reject/)
      @vu[k1]['rrej']['tot'] += 1
      @vu[k1]['rrej']['dum'] += 1 if v.military?
      @vu[k1]['rrej']['dgm'] += 1 if v.male?
      @vu[k1]['rrej']['dgf'] += 1 if v.female?
      @vu[k1]['rrej']['dpd'] += 1 if v.party_democratic?
      @vu[k1]['rrej']['dpr'] += 1 if v.party_republican?
      if (vtr.note =~ /late/)
        @vu[k1]['rrej']['dla'] += 1
        @vu[k1]['rrej']['dlm'] += 1 if v.military?
      end
    end
  end

  def voter_uocava_report_compute(nova)
    @uvoters = []

    @election.voters.each do |v|
      if v.uocava?
        @vu['aab']['tota']['tot'] += 1
        @vu['aab']['tota']['abs'] += 1 if v.absentee_status?
        @vu['aab']['tota']['abl'] += 1 if v.absentee_ulapsed?
        foundrm, foundrc, foundam, foundac = 0, 0, 0, 0
        v.vtrs.each do |vtr|
          if (vtr.form =~ /Voter/ || vtr.form =~ /Request/)
            foundrm += 1
            foundrc += 1 if vtr.action=~/complete/
            @vu['aur']['rrec']['tot'] += 1 if vtr.action=~/match/ || vtr.action=~/transcribe/
            @vu['aur']['rapp']['tot'] += 1 if vtr.action=~/approve/
            @vu['aur']['rrej']['tot'] += 1 if vtr.action=~/reject/
            if (vtr.form =~ /VoterRegistration/)
              voter_uocava_report_form(vtr, v, 'arr')
            elsif (vtr.form =~ /VoterRecordUpdate/)
              voter_uocava_report_form(vtr, v, 'aru')
            elsif (vtr.form =~ /AbsenteeRequest/)
              voter_uocava_report_form(vtr, v, 'aas')
            end
          elsif (vtr.form =~ /AbsenteeBallot/)
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
          if (vtr.form =~ /VoterRegistration/)
            voter_uocava_domestic_form(vtr, v, 'arr')
          elsif (vtr.form =~ /VoterRecordUpdate/)
            voter_uocava_domestic_form(vtr, v, 'aru')
          elsif (vtr.form =~ /AbsenteeRequest/)
            voter_uocava_domestic_form(vtr, v, 'aas')
          elsif (vtr.form =~ /AbsenteeBallot/)
            voter_uocava_domestic_form(vtr, v, 'aab')
          end
        end
      end
      voter_record_report_update(@va, v, @election) if nova
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
