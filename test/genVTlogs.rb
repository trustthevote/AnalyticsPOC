
@uocava_voters = 50
@uocava_mil = 70
@uocava_ab_email = 60

@domestic_ab = 8

@male_percent = 47

@registered = 50
@approval_vr = 90
@approval_ru = 90
@approval_ar = 90
@approval_ab = 70
@approval_pb = 70
@voting_yes = 80

@states = Hash.new { |h, k| h[k] = { } }
@states = {

# Start
  0 => {"action" => "",
    "comment" => "registered?",
    "transition" => [@registered,19,9]},

  9 => {"action" => "",
    "comment" => "is UOCAVA?",
    "transition" => ['isUOCAVA',10,100]},

  10 => {"action" => "sentToVoter",
    "form" => "VoterRegistration",
    "notes" => "randomSent",
    "comment" => "continue",
    "transition" => [88,14,-1]},
  11 => {"action" => "",
    "transition" => [60,12,13]},
  12 => {"action" => "complete",
    "form" => "VoterRegistration",
    "formNote" => "onlineGenerated",
    "transition" => [100,14]},
  13 => {"action" => "complete",
    "form" => "VoterRegistration",
    "formNote" => "FPCA",
    "transition" => [100,14]},
  14 => {"action" => "",
    "form" => "VoterRegistration",
    "comment" => "mail",
    "transition" => [95,15,11]},
  15 => {"action" => "receive",
    "form" => "VoterRegistration",
    "comment" => "receive",
    "formNote" => "onlineGenerated",
    "notes" => "randomReceive",
    "transition" => [96,16,11]},
  16 => {"action" => "",
    "form" => "VoterRegistration",
    "comment" => "review",
    "leo" => "Leonidas VR",
    "transition" => [@approval_vr,17,18]},
  17 => {"action" => "approve",
    "form" => "VoterRegistration",
    "formNote" => "onlineGenerated",
    "comment" => "approve",
    "leo" => "Leonidas VR",
    "transition" => [100,20]},
  18 => {"action" => "reject",
    "form" => "VoterRegistration",
    "formNote" => "onlineGenerated",
    "comment" => "reject",
    "leo" => "Leonidas VR",
    "notes" => "randomReject",
    "transition" => [100,11]},

  19 => {"action" => "",
    "comment" => "is UOCAVA?",
    "transition" => ['isUOCAVA',20,200]},
  20 => {"action" => "",
    "comment" => "upd?",
    "transition" => [50,29,21]},
  21 => {"action" => "sentToVoter",
    "form" => "VoterRecordUpdate",
    "notes" => "randomSent",
    "comment" => "unupd",
    "transition" => [60,22,23]},
  22 => {"action" => "complete",
    "form" => "VoterRecordUpdate",
    "transition" => [100,24]},
  23 => {"action" => "complete",
    "form" => "VoterRecordUpdate",
    "formNote" => "FPCA",
    "transition" => [100,24]},
  24 => {"action" => "",
    "form" => "VoterRecordUpdate",
    "comment" => "mail",
    "transition" => [95,25,21]},
  25 => {"action" => "receive",
    "form" => "VoterRecordUpdate",
    "formNote" => "onlineGenerated",
    "comment" => "receive",
    "notes" => "randomReceive",
    "transition" => [96,26,21]},
  26 => {"action" => "",
    "form" => "VoterRecordUpdate",
    "comment" => "review",
    "leo" => "Leonidas VRU",
    "transition" => [@approval_ru,27,28]},
  27 => {"action" => "approve",
    "form" => "VoterRecordUpdate",
    "formNote" => "onlineGenerated",
    "comment" => "approve",
    "leo" => "Leonidas VRU",
    "transition" => [100,29]},
  28 => {"action" => "reject",
    "form" => "VoterRecordUpdate",
    "comment" => "reject",
    "formNote" => "onlineGenerated",
    "leo" => "Leonidas VRU",
    "notes" => "randomReject",
    "transition" => [100,21]},
  29 => {"action" => "",
    "comment" => "is UOCAVA?",
    "transition" => ['isUOCAVA',300,500]},

# Register to Vote
  100 => {"action" => "sentToVoter",
    "form" => "VoterRegistration",
    "notes" => "randomSent",
    "comment" => "continue",
    "transition" => [88,104,-1]},
  101 => {"action" => "",
    "transition" => [60,102,103]},
  102 => {"action" => "complete",
    "form" => "VoterRegistration",
    "transition" => [100,104]},
  103 => {"action" => "complete",
    "form" => "VoterRegistration",
    "formNote" => "FPCA",
    "transition" => [100,104]},
  104 => {"action" => "",
    "form" => "VoterRegistration",
    "comment" => "mail",
    "transition" => [95,105,101]},
  105 => {"action" => "receive",
    "form" => "VoterRegistration",
    "comment" => "receive",
    "notes" => "randomReceive",
    "transition" => [96,106,101]},
  106 => {"action" => "",
    "form" => "VoterRegistration",
    "comment" => "review",
    "leo" => "Leonidas VR",
    "transition" => [@approval_vr,107,108]},
  107 => {"action" => "approve",
    "form" => "VoterRegistration",
    "comment" => "approve",
    "leo" => "Leonidas VR",
    "transition" => [100,200]},
  108 => {"action" => "reject",
    "form" => "VoterRegistration",
    "comment" => "reject",
    "leo" => "Leonidas VR",
    "notes" => "randomReject",
    "transition" => [100,101]},

# Record Update
  200 => {"action" => "",
    "comment" => "upd?",
    "transition" => [50,209,201]},
  201 => {"action" => "sentToVoter",
    "form" => "VoterRecordUpdate",
    "notes" => "randomSent",
    "comment" => "unupd",
    "transition" => [60,202,203]},
  202 => {"action" => "complete",
    "form" => "VoterRecordUpdate",
    "transition" => [100,204]},
  203 => {"action" => "complete",
    "form" => "VoterRecordUpdate",
    "formNote" => "FPCA",
    "transition" => [100,204]},
  204 => {"action" => "",
    "form" => "VoterRecordUpdate",
    "comment" => "mail",
    "transition" => [95,205,201]},
  205 => {"action" => "receive",
    "form" => "VoterRecordUpdate",
    "comment" => "receive",
    "notes" => "randomReceive",
    "transition" => [96,206,201]},
  206 => {"action" => "",
    "form" => "VoterRecordUpdate",
    "comment" => "review",
    "leo" => "Leonidas VRU",
    "transition" => [@approval_ru,207,208]},
  207 => {"action" => "approve",
    "form" => "VoterRecordUpdate",
    "comment" => "approve",
    "leo" => "Leonidas VRU",
    "transition" => [100,209]},
  208 => {"action" => "reject",
    "form" => "VoterRecordUpdate",
    "comment" => "reject",
    "leo" => "Leonidas VRU",
    "notes" => "randomReject",
    "transition" => [100,201]},
  209 => {"action" => "",
    "comment" => "is UOCAVA?",
    "transition" => ['isUOCAVA',300,500]},

# UOCAVA Absentee Request
  300 => {"action" => "",
    "comment" => "voting?20",
    "transition" => [88,311,-1]},
  310 => {"action" => "sentToVoter",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "comment" => "voting?20",
    "notes" => "randomSent",
    "transition" => [100,311]},
  311 => {"action" => "identify",
    "comment" => "online-id21",
    "transition" => [60,312,313]},
  312 => {"action" => "start",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "comment" => "start22",
    "transition" => [95,314,315]},
  313 => {"action" => "start",
    "form" => "AbsenteeRequest",
    "formNote" => "FPCA",
    "comment" => "start22",
    "transition" => [95,314,315]},
  314 => {"action" => "complete",
    "form" => "AbsenteeRequest",
    "formNote" => "FPCA",
    "comment" => "complete24",
    "transition" => [88,317,-1]},
  315 => {"action" => "discard",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "comment" => "discard25",
    "transition" => [100,310]},
  317 => {"action" => "receive",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "notes" => "randomReceive",
    "comment" => "review27",
    "leo" => "Leonidas AR",
    "transition" => [@approval_ar,318,319]},
  318 => {"action" => "approve",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "comment" => "approve28",
    "leo" => "Leonidas AR",
    "transition" => ['isUOCAVA',411,900]},
  319 => {"action" => "reject",
    "form" => "AbsenteeRequest",
    "formNote" => "onlineGenerated",
    "comment" => "reject29",
    "leo" => "Leonidas AR",
    "notes" => "randomReject",
    "transition" => [100,310]},
  
# UOCAVA Absentee Ballot
  400 => {"action" => "",
    "comment" => "voting?",
    "transition" => [88,401,-1]},
  401 => {"action" => "identify",
    "comment" => "online id",
    "transition" => [60,411,402]},
  402 => {"action" => "sentToVoter",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "notes" => "randomSent",
    "comment" => "online id",
    "transition" => [50,412,413]},
  411 => {"action" => "start",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "start",
    "transition" => [95,414,415]},
  412 => {"action" => "start",
    "form" => "AbsenteeBallot",
    "formNote" => "FPCA",
    "comment" => "start",
    "transition" => [95,414,415]},
  413 => {"action" => "start",
    "form" => "AbsenteeBallot",
    "formNote" => "FWAB",
    "comment" => "start",
    "transition" => [95,414,415]},
  414 => {"action" => "complete",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "complete",
    "transition" => [88,416,-1]},
  415 => {"action" => "discard",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "discard",
    "transition" => [100,400]},
  416 => {"action" => "submit",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "submit",
    "transition" => [100,417]},
  417 => {"action" => "receive",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "notes" => "randomReceive",
    "comment" => "review",
    "leo" => "Leonidas AB",
    "transition" => [@approval_ab,418,419]},
  418 => {"action" => "approve",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "approve",
    "leo" => "Leonidas AB",
    "transition" => [88,-1,412]},
  419 => {"action" => "",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "reject",
    "transition" => [57,498,499]},
  498 => {"action" => "reject",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "reject",
    "leo" => "Leonidas AB",
    "notes" => "randomReject",
    "transition" => [88,-1,412]},
  499 => {"action" => "reject",
    "form" => "AbsenteeBallot",
    "formNote" => "onlineGenerated",
    "comment" => "reject",
    "leo" => "Leonidas AB",
    "notes" => "randomReject",
    "transition" => [88,-1,412]},
  
# Domestic Absentee Request
  500 => {"action" => "",
    "comment" => "voting?",
    "transition" => [100,506,-1]},
  506 => {"action" => "",
    "comment" => "ballotReg?",
    "transition" => [70,600,507]},
  507 => {"action" => "",
    "comment" => "ballotAB?",
    "transition" => [30,700,800]},

# Domestic Vote Regular
  600 => {"action" => "",
    "comment" => "some do not vote",
    "transition" => [@voting_yes,601,-1]},
  601 => {"action" => "identify",
    "form" => "PollBookEntry",
    "comment" => "id at polls",
    "transition" => [100,-1]},

# Domestic Vote Provisional
  700 => {"action" => "",
    "form" => "ProvisionalBallot",
    "comment" => "vote provisional",
    "transition" => [100,701]},
  701 => {"action" => "",
    "form" => "ProvisionalBallot",
    "comment" => "vote provisional",
    "transition" => [88,707,-1]},
  707 => {"action" => "receive",
    "form" => "ProvisionalBallot",
    "notes" => "randomReceive",
    "comment" => "review",
    "leo" => "Leonidas PB",
    "transition" => [@approval_pb,708,709]},
  708 => {"action" => "approve",
    "form" => "ProvisionalBallot",
    "comment" => "approve",
    "leo" => "Leonidas PB",
    "transition" => [100,-1]},
  709 => {"action" => "reject",
    "form" => "ProvisionalBallot",
    "comment" => "reject",
    "leo" => "Leonidas PB",
    "notes" => "randomReject",
    "transition" => [100,-1]},

# Domestic Absentee Request
  800 => {"action" => "",
    "form" => "AbsenteeRequest",
    "comment" => "vote absentee80",
    "transition" => [50,311,801]},
  801 => {"action" => "",
    "form" => "AbsenteeRequest",
    "comment" => "vote absentee80",
    "transition" => [88,805,-1]},
  805 => {"action" => "",
    "form" => "AbsenteeRequest",
    "comment" => "review77",
    "leo" => "Leonidas AR",
    "transition" => [80,807,806]},
  806 => {"action" => "returnedUndelivered",
    "form" => "AbsenteeRequest",
    "notes" => "postalReceived",
    "comment" => "review77",
    "leo" => "Leonidas AR",
    "transition" => [100,-1]},
  807 => {"action" => "receive",
    "form" => "AbsenteeRequest",
    "notes" => "randomReceive",
    "comment" => "review77",
    "leo" => "Leonidas AR",
    "transition" => [@approval_ar,808,809]},
  808 => {"action" => "approve",
    "form" => "AbsenteeRequest",
    "comment" => "approve78",
    "leo" => "Leonidas AR",
    "transition" => [100,900]},
  809 => {"action" => "reject",
    "form" => "AbsenteeRequest",
    "comment" => "reject79",
    "leo" => "Leonidas AR",
    "notes" => "randomReject",
    "transition" => [100,-1]},

# Domestic Absentee Ballot 
  900 => {"action" => "",
    "form" => "AbsenteeBallot",
    "comment" => "vote absentee",
    "transition" => [50,411,901]},
  901 => {"action" => "",
    "form" => "AbsenteeBallot",
    "comment" => "vote absentee90",
    "transition" => [88,905,-1]},
  905 => {"action" => "",
    "form" => "AbsenteeBallot",
    "comment" => "review77",
    "leo" => "Leonidas AR",
    "transition" => [80,907,906]},
  906 => {"action" => "returnedUndelivered",
    "form" => "AbsenteeBallot",
    "notes" => "postalReceived",
    "comment" => "review77",
    "leo" => "Leonidas AR",
    "transition" => [100,-1]},
  907 => {"action" => "receive",
    "form" => "AbsenteeBallot",
    "notes" => "randomReceive",
    "comment" => "review",
    "leo" => "Leonidas AB",
    "transition" => [@approval_ab,908,909]},
  908 => {"action" => "approve",
    "form" => "AbsenteeBallot",
    "comment" => "approve",
    "leo" => "Leonidas AB",
    "transition" => [100,-1]},
  909 => {"action" => "reject",
    "form" => "AbsenteeBallot",
    "comment" => "reject",
    "leo" => "Leonidas AB",
    "notes" => "randomReject",
    "transition" => [100,-1]},

# Done
  1000 => {"action" => "",
    "form" => "",
    "comment" => "stop",
    "transition" => [100,-1]}
}

@voterStatus = Hash.new { |h,k| h[k] = { } }
@filename = "VTlogs/voter_recs"

@nvoters = 10
@nlogs = 4
@nuocava = 0
@vstart = 0
@daycount = 1
@debugit = false
@computed_vtrs = 0
@count_vtrs = 0
@all_vtrs = ''

def notDone()
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStatus[vname]
    vstaten = vstate["state"]
    return true if vstaten >= 0
  end
  return false
end

def genVoterStatus()
  (1..@nvoters).each do |n| 
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    @voterStatus[vname] = {"state" => 0, "vform"=> '', "actions" => []}
    (vrtype,vrgend,vrparty,vrmil,vrover,vrabs,vrabpref) = genVoterRecord(vname)
    if (vrtype == 'UOCAVA')
      @voterStatus[vname]["vtype"] = vrtype
    end
    @voterStatus[vname]["vrtype"] = vrtype
    @voterStatus[vname]["vrgend"] = vrgend
    @voterStatus[vname]["vrparty"] = vrparty
    @voterStatus[vname]["vrmil"] = vrmil
    @voterStatus[vname]["vrover"] = vrover
    @voterStatus[vname]["vrabs"] = vrabs
    @voterStatus[vname]["vrabpref"] = vrabpref
  end
end

def genVoterRecord(vname)
  debug('Voter: '+vname)
  vrmil = 'N'
  vrover = 'N'
  vrabs = 'N'
  vrabpref = ''
  if rand(100) < @uocava_voters
    vrtype = 'UOCAVA'
    vrabs = 'Y'
    if rand(100) < @uocava_mil
      vrmil = 'Y'
    else
      vrover = 'Y'
    end
    @nuocava += 1
    if rand(100) < @uocava_ab_email
      vrabpref = 'email'
    else
      vrabpref = 'postal'
    end
  else
    vrtype = 'domestic'
    if rand(100) < @domestic_ab
      vrabs = 'Y'
      vrabpref = 'postal'
    end
  end
  debug('Type: '+vrtype)
  if rand(100) < @male_percent
    vrgend = 'M'
  else
    vrgend = 'F'
  end
  debug('Gend: '+vrgend)
  ppercent = rand(100)
  spercent = 0
  vrparty = ''
  if (0 <= ppercent && ppercent < 45)     # %Democratic
    vrparty = 'Democratic'
  elsif (45 <= ppercent && ppercent < 90) # %Republican
    vrparty = 'Republican'
  else                                    # %Green
    vrparty = 'Green'
  end
  debug('Party: '+vrparty)
  return [vrtype, vrgend, vrparty, vrmil, vrover, vrabs, vrabpref]
end

def transVoterStatus()
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStatus[vname]
    (vstate["state"], vactions) = stateTrans(vname, vstate)
  end
end

def extractVTR(voter, state, vstate)
  action="action:"+state["action"]
  leo=(state.keys.include?("leo") ? "leo:"+state["leo"] : "")
  notes=handleNotes(state)
  comments=(state.keys.include?("comments") ? "comments:"+state["comments"]:"")
  if state.keys.include?("form")
    if state.keys.include?("formNote")
      form = "form:"+state["form"]+"_"+state["formNote"]
      vstate["vform"]=state["form"]+"_"+state["formNote"]
    else
      form = state["form"]
      lastform = extractLastForm(vstate)
      if lastform.index(form)
        form = "form:"+lastform
      else
        form = "form:"+form
      end
    end
  else
    form = "form:none"
  end
  val="voterid:"+voter+";"+action+";"+form+";"+leo+";"+notes+";"+comments+";"
  return val+"jurisdiction:virginia"+";"
end

def randomSomething(something)
  n = rand(100)
  case something
  when "randomReject"
  then
    return "rejectLate" if n < 34
    return "rejectUnsigned" if n < 67
    return "rejectIncomplete"
  when "randomReceive"
    then
    return "postalReceived" if n < 51
    return "personalReceived" if n < 81
    return "faxReceived"
  when "randomSent"
  then
    return "postalSent" if n < 71
    return "emailSent"
  end
  return ""
end

def handleNotes(state)
  if (state.keys.include?("notes"))
    notes = state["notes"]
    if notes =~ /^(random.*)$/
      return "notes:"+randomSomething($1)
    else
      return "notes:"+notes
    end
    return ""
  end
  return ""
end

def extractLastForm(vstate)
  return "" if vstate["actions"].length <= 0
  #debug('Vstate1: '+vstate["actions"][-1])
  if vstate["actions"][-1] =~ /form:([^;]*)/
    lastform = $1
    #debug('Vstate2: '+lastform)
    return lastform
  else
    return ""
  end
end
    
def isUOCAVA(vname)
  if @voterStatus[vname].keys.include?('vtype')
    return @voterStatus[vname]['vtype'] == 'UOCAVA'
  else
    return false
  end
end

def stateTrans(vname, vstate)
  vstaten = vstate["state"]
  vactions = vstate["actions"]
  return [vstaten, vactions] if vstaten < 0
  error("Unknown state: "+vstaten.to_s) unless @states.keys.include?(vstaten)
  newstate = @states[vstaten]
  if newstate["action"].length > 0
    action = extractVTR(vname, newstate, vstate)
    @computed_vtrs += 1
  end
  transition = newstate["transition"]
  percentage = transition[0]
  if percentage == 'isUOCAVA'
    if isUOCAVA(vname)
      staten = transition[1]
    else
      staten = transition[2]
    end
  else
    if percentage >= 100
      staten = transition[1]
    elsif rand(100) <= percentage
      staten = transition[1]
    else
      staten = transition[2]
    end
  end
  vactions.push(action) if action
  return [staten, action]
end

def error(msg)
  print "**ERROR** "+msg+"\n"
  exit(1)
end

def debug(msg)
  if @debugit
    print "**DEBUG** "+msg+"\n"
  end
end

def dumpVoterStatus(vtrs, datime)
  n = @count_vtrs
  text = vtrs
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStatus[vname]
    if vstate['actions'].length > 0
      text += dumpVoterStatum(vstate['actions'].shift, datime)
    end
  end
  return [text, (@count_vtrs-n), datime]
end

def dumpVoterStatum(cstring, datime)
  text = "  <voterTransactionRecord>\n    <date>"+datime+"</date>\n"
  cstring.split(';').each do |s|
    (field, value) = s.split(':')
    unless value == nil
      if field=="form" && value.index('_')
        (form, formNote) = value.split('_')
        text += "    <form>"+form+"</form>\n"
        text += "    <formNote>"+formNote+"</formNote>\n"
      else
        text += "    <"+field+">"+value+"</"+field+">\n"
      end
    end
  end
  text += "  </voterTransactionRecord>\n"
  @count_vtrs += 1
  @all_vtrs += text
  return text
end

def printFile(text, n, nvtrs, flag = false)
  filename="VTlogs/voter_trans_"+@nvoters.to_s
  if flag
    filename += ".xml"
    printFileReally(filename, text, nvtrs)
  # else
  #   filename += "_"+n.to_s+".xml"
  #   printFileReally(filename, text, nvtrs)
  end
end

def printFileReally(filename, text, nvtrs)
  print "Printing Log to File: "+filename+" (#VTRS: "+nvtrs.to_s+")\n"
  f = File.open(filename,"w")
  f.print text
  f.close
end

def printVoterRecords()
  unless @filename =~ /csv$/
    @filename = @filename+"_"+@nvoters.to_s+".csv"
  end
  print "Printing CSV File: "+@filename+" (#UOCAVA: "+@nuocava.to_s+")\n"
  if f = File.open(@filename,"w")
    f.print "Voter,Gender,Party,Military,Overseas,Absentee,RegDate,ABpref\n"
    @voterStatus.each do |k,v|
      regdate = '2010/1/1'
      regdate = @vregdate if rand(100) < 50
      f.print k.to_s+","+v['vrgend']+","+v['vrparty']+","+v['vrmil']+","+
        v['vrover']+","+v['vrabs']+","+regdate+","+v['vrabpref']+"\n"
    end
  else
    error('Failed opening file for write: '+@filename)
  end
end

def makeTransLog(text, datime)
  uniq = @nvoters
  @daycount += 1
  header  = "  <header>\n"
  header += "    <origin>Virginia</origin>\n"
  header += "    <originUniq>"+uniq.to_s+"</originUniq>\n"
  header += "    <createDate>"+datime+"</createDate>\n"
  header += "    <hashAlg>none</hashAlg>\n"
  header += "  </header>\n"
  return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+
    "<voterTransactionLog>\n"+header+text+"</voterTransactionLog>\n"
end

def printVoterStatus()
  @voterStatus.keys.each do |v|
    print v+": "+@voterStatus[v].to_s+"\n"
  end
end

def datimeInit()
  datime = "2012-09-01T10:10:00Z"
  (year, month, day) = datime.split('-')
  return datime, month.to_i, day.to_i
end

def datimePlus1 (datime, month, day)
  predatime = "2012-"
  predatime = "2012-0" if month < 10
  day = day + 1
  if day > 30
    month += 1
    day = 1
  end
  datime = predatime+month.to_s+"-"
  if (day < 10)
    datime += "0"+day.to_s+"T10:10:00Z"
  else
    datime += day.to_s+"T10:10:00Z"
  end
  return datime, month, day
end

begin
  if ARGV.length > 0
    @nvoters = ARGV.shift.to_i
  end
  if ARGV.length > 0
    @vregdate = ARGV.shift
  else
    @vregdate = "2012/10/10"
  end
  if ARGV.length > 0
    @vstart = ARGV.shift.to_i
  end
  genVoterStatus()
  if @debugit
    printVoterStatus()
  end
  count = 1
  while (count < 100 and notDone())
    transVoterStatus()
    if @debugit
      printVoterStatus()
    end
    count += 1
  end
  printVoterRecords()
  print "# Voters: "+@nvoters.to_s+"\n"
  print "# Reg Date: "+@vregdate.to_s+"\n" if @vregdate
  print "# Iterations: "+count.to_s+"\n"
  print "# Computed VTRs: "+@computed_vtrs.to_s+"\n"
  allvtrs = ""
  (datime, month, day) = datimeInit()
  predatime = "2012-0"
  incvtrs = Integer(@computed_vtrs/@nlogs)+1
  print "# Incremental VTRs: "+incvtrs.to_s+"\n"
  vtrs = ''
  nvtrs = 0
  n = 0
  notdone = true
  file_count = 1
  count = 0
  while (notdone)
    print "Count: "+file_count.to_s+" n: "+n.to_s+"\n"
    (vtrs, n, datime) = dumpVoterStatus(vtrs, datime)
    if (n == 0)
      unless nvtrs == 0
        printFile(makeTransLog(vtrs,datime),file_count,nvtrs)
      end
      notdone = false
    else
      if (nvtrs+n > incvtrs)
        printFile(makeTransLog(vtrs,datime),file_count,nvtrs+n)
        file_count += 1
        vtrs = ''
        nvtrs = 0
      else
        nvtrs += n
      end
      (datime, month, day) = datimePlus1(datime, month, day)
    end
  end
  printFile(makeTransLog(@all_vtrs,datime),file_count,@computed_vtrs,flag=true)
end
