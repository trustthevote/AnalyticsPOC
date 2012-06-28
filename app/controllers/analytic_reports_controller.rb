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

# Data type names
# 
# @?v ? Voters
#
# @av All
# @vv Voting (Participating)
# @uv UOCAVA
# @dv Domestic
# @nv Not Voting
#
# Keys
  # total - Total
  # voted - Voted
  # gf    - Gender Female
  # gm    - Gender Male
  # pd    - Party Democrat
  # pr    - Party Republican
  # po    - Party Other
  # abs   - Absentee Status
  # absla - Absentee Status Lapsed

  # rr    - Registration Request
  # rrm   - Registration Request Matched
  # rra   - Registration Request Approved
    # um  - Registration Request Approved UOCAVA Military
    # uo  - Registration Request Approved UOCAVA Other
  # rrr   - Registration Request Rejected
    # gf  - Registration Request Rejected Gender Female
    # gm  - Registration Request Rejected Gender Male
    # pd  - Registration Request Rejected Party Democrat
    # pr  - Registration Request Rejected Party Republican
    # po  - Registration Request Rejected Party Other
    # um  - Registration Request Rejected UOCAVA Military
    # uo  - Registration Request Rejected UOCAVA Other
    # rl  - Registration Request Rejected Late
    # ro  - Registration Request Rejected Other Reason

  # ru    - Record Update
  # rum   - Record Update Matched
  # rua   - Record Update Approved
    # um  - Record Update Approved UOCAVA Military
    # uo  - Record Update Approved UOCAVA Other
  # rur   - Record Update Rejected
    # gf  - Record Update Rejected Gender Female
    # gm  - Record Update Rejected Gender Male
    # pd  - Record Update Rejected Party Democrat
    # pr  - Record Update Rejected Party Republican
    # po  - Record Update Rejected Party Other
    # um  - Record Update Rejected UOCAVA Military
    # uo  - Record Update Rejected UOCAVA Other
    # rl  - Record Update Rejected Late
    # ro  - Record Update Rejected Other Reason

  # as    - Absentee Status
  # asm   - Absentee Status Matched
  # asa   - Absentee Status Approved
    # um  - Absentee Status Approved UOCAVA Military
    # uo  - Absentee Status Approved UOCAVA Other
  # asr   - Absentee Status Rejected
    # gf  - Absentee Status Rejected Gender Female
    # gm  - Absentee Status Rejected Gender Male
    # pd  - Absentee Status Rejected Party Democrat
    # pr  - Absentee Status Rejected Party Republican
    # po  - Absentee Status Rejected Party Other
    # um  - Absentee Status Rejected UOCAVA Military
    # uo  - Absentee Status Rejected UOCAVA Other
    # rl  - Absentee Status Rejected Late
    # ro  - Absentee Status Rejected Other Reason

  # vi    - Voted In-Person

  # va    - Voted Absentee
  # vaa   - Voted Absentee Approved
    # um  - Voted Absentee Approved UOCAVA Military
    # uo  - Voted Absentee Approved UOCAVA Other
  # var   - Voted Absentee Rejected
    # gf  - Voted Absentee Rejected Gender Female
    # gm  - Voted Absentee Rejected Gender Male
    # pd  - Voted Absentee Rejected Party Democrat
    # pr  - Voted Absentee Rejected Party Republican
    # po  - Voted Absentee Rejected Party Other
    # ul  - Voted Absentee Rejected UOCAVA Late
    # ulm - Voted Absentee Rejected UOCAVA Late Military
    # ulo - Voted Absentee Rejected UOCAVA Late Other
    # um  - Voted Absentee Rejected UOCAVA Military
    # uo  - Voted Absentee Rejected UOCAVA Other
    # rl  - Voted Absentee Rejected Late
    # ro  - Voted Absentee Rejected Other Reason

  # vp    - Voted Provisional
  # vpa   - Voted Provisional Approved
  # vpr   - Voted Provisional Rejected

  # vnot  - Did Not Vote

  def report
    case @rn
    when 0
      self.report1()
    else
      @trv, @trva, @trdv, @trdva = 0,0,0,0  # Tot Registered/Domestic/Domestic+Abs Voters
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
      @trv = @election.voters.count if VoterRecord.count==0
      @election.voters.each do |v|
        if VoterRecord.count==0 
          @trvm += 1 if v.male
          @trvf += 1 if v.female
          @trvd += 1 if v.party_democratic
          @trvr += 1 if v.party_republican
          @trvo += 1 if v.party_other
          @trva += 1 if v.absentee_status
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
          if VoterRecord.count==0
            @truv += 1
            @truvm += 1 if v.military
            @truvla += 1 if v.absentee_ulapsed
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
          if VoterRecord.count==0
            @trdv += 1
            @trdva += 1 if v.voted_absentee
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
      if VoterRecord.count > 0
        @trv = VoterRecord.count
        VoterRecord.all.each do |v|
          @trvm += 1 if v.male
          @trvf += 1 if v.female
          @trvd += 1 if v.party_democratic
          @trvr += 1 if v.party_republican
          @trvo += 1 if v.party_other
          @trva += 1 if v.absentee_status
          if v.new #JVC
          end
          if (v.vtype=="UOCAVA")
            @truv += 1
            @truvm += 1 if v.military
            @truvla += 1 if v.absentee_ulapsed
          else
            @trdv += 1
            @trdva += 1 if v.absentee_status
          end
        end
      end
      @trnv = @tpnv
      @trnvm = @tpnvm
      @trnvf = @tpnvf
      @trnvd = @tpnvd
      @trnvr = @tpnvr
      @trnvo = @tpnvo
      @tpdvpap = self.percent(@tpdvpa,@tpdvp)
      @tpvp =   self.percent(@tpv,@trv)
      @tpdvip =  self.percent(@tpdvi,@trv)
      @tpdvap =  self.percent(@tpdva,@trv)
      @tpdvpp =  self.percent(@tpdvp,@trv)
      @tpdvpap = self.percent(@tpdvpa,@tpdvpa+@tpdvpr)
      @tpuvp =   self.percent(@tpuv,@trv)
      @tpuvmp =  self.percent(@tpuvm,@trv)
      @tpuvlap = self.percent(@tpuvla,@trv)
      @truvo = @truv - @truvm
      @truvmp = self.percente(@truvm,@truv)
      @truvop = self.percente(@truvo,@truv)
      @avp1p = self.percent(@trv-(@tpdvi+@tpdva+@tpdvp+@tpuvv),@trv)
      @avp2p = self.percent(@tpdvi,@trv)
      @avp3p = self.percent(@tpdvaa+@tpuva,@trv)
      @avp4p = self.percent(@tpdvar+@tpuvr,@trv)
      @avp5p = self.percent(@tpdvpa,@trv)
      @avp6p = self.percent(@tpdvpr,@trv)
      @anp1p = self.percent(@tnv-(@tndvi+@tndva+@tndvp+@tnuvv),@trv)
      @anp2p = self.percent(@tndvi,@tnv)
      @anp3p = self.percent(@tndvaa+@tnuva,@tnv)
      @anp4p = self.percent(@tndvar+@tnuvr,@tnv)
      @anp5p = self.percent(@tndvpa,@tnv)
      @anp6p = self.percent(@tndvpr,@tnv)
      @trvmp = self.percent(@trvm,@trv)
      @trvfp = self.percent(@trvf,@trv)
      @trvdp = self.percent(@trvd,@trv)
      @trvrp = self.percent(@trvr,@trv)
      @trvop = self.percent(@trvo,@trv)
      @tpvmp = self.percent(@tpvm,@tpv)
      @tpvfp = self.percent(@tpvf,@tpv)
      @tpvdp = self.percent(@tpvd,@tpv)
      @tpvrp = self.percent(@tpvr,@tpv)
      @tpvop = self.percent(@tpvo,@tpv)
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
      vhash['vra'] += 1 if (v.vform=~/Regular/)
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
      #"tot"=>0,"vno"=>0,"vra"=0,"vpa"=>0,"vpr"=>0,"vaa"=>0,"varl"=>0,"varo"=>0,
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
    @avotersp = self.report2percent(@avoters,@trv)
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

    @urm_usep = self.percent(@urm_use,@truv)
    @urm_completep = self.percent(@urm_complete,@truv)
    @urm_completep_reg = self.percent(@urm_complete,@urm_use)
    @uam_usep = self.percent(@uam_use,@truv)
    @uam_completep = self.percent(@uam_complete,@truv)
    @uam_completep_reg = self.percent(@uam_complete,@urm_use)
    
    @usr_generated = @urr_generated+@uru_generated+@uar_generated+@uab_generated
    @usr_receivedp = self.percent(@usr_received,@truv)
    @usr_ab_voters = @uam_complete
    @usr_lost = [@usr_generated-@usr_received,0].max
    @usr_approvedp = self.percent_parens(@usr_approved,@usr_received)
    @usr_rejectedp = self.percent_parens(@usr_rejected,@usr_received)
    @usr_lostp = self.percent_forms(@usr_lost,@usr_generated)

    @urr_receivedp = self.percent(@urr_received,@truv)
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
    @urr_lost = [@urr_generated-@urr_received,0].max
    @urr_approvedp = self.percent_parens(@urr_approved,@urr_received)
    @urr_rejectedp = self.percent_parens(@urr_rejected,@urr_received)
    @urr_lostp = self.percent_forms(@urr_lost,@urr_generated)
    @urr_new = self.percent(@urr_approved,@trv)

    @uru_receivedp = self.percent(@uru_received,@truv)
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
    @uru_lost = [@uru_generated-@uru_received,0].max
    @uru_approvedp = self.percent_parens(@uru_approved,@uru_received)
    @uru_rejectedp = self.percent_parens(@uru_rejected,@uru_received)
    @uru_lostp = self.percent_forms(@uru_lost,@uru_generated)

    @uar_receivedp = self.percent(@uar_received,@truv)
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
    @uar_lost = [@uar_generated-@uar_received,0].max
    @uar_approvedp = self.percent_parens(@uar_approved,@uar_received)
    @uar_rejectedp = self.percent_parens(@uar_rejected,@uar_received)
    @uar_lostp = self.percent_forms(@uar_lost,@uar_generated)

    @uab_receivedp = self.percent(@uab_received,@truv)
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
    @uab_lost = [@uab_generated-@uab_received,0].max
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
