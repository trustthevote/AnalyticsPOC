
@approval_vr = 90
@approval_vru = 90
@approval_ar = 90
@approval_ab = 70
@approval_pb = 70

@states = Hash.new { |h, k| h[k] = { } }
@states = {
  0 => {"action" => "",
    "desc" => "reg?",
    "trans" => [50, 10, 1]},
  1 => {"action" => "",
    "desc" => "unreg",
    "trans" => [70, 2, 3]},
  2 => {"action" => "",
    "form" => "Voter Registration",
    "desc" => "getoff",
    "trans" => [100, 4]},
  3 => {"action" => "",
    "form" => "Voter Registration",
    "desc" => "geton",
    "trans" => [100, 4]},
  4 => {"action" => "",
    "form" => "Voter Registration",
    "desc" => "mail",
    "trans" => [95, 5, 1]},
  5 => {"action" => "match",
    "form" => "Voter Registration",
    "desc" => "match",
    "trans" => [96, 6, 1]},
  6 => {"action" => "",
    "form" => "Voter Registration",
    "desc" => "review",
    "leo" => "Leonidas VR",
    "trans" => [@approval_vr, 7, 8]},
  7 => {"action" => "approve",
    "form" => "Voter Registration",
    "desc" => "approve",
    "leo" => "Leonidas VR",
    "trans" => [100, 10]},
  8 => {"action" => "reject",
    "form" => "Voter Registration",
    "desc" => "reject",
    "leo" => "Leonidas VR",
    "note" => "not signed VR",
    "trans" => [100, 1]},

  10 => {"action" => "",
    "desc" => "upd?",
    "trans" => [50, 19, 11]},
  11 => {"action" => "",
    "desc" => "unupd",
    "trans" => [70, 12, 13]},
  12 => {"action" => "",
    "form" => "Voter Record Update",
    "desc" => "getoff",
    "trans" => [100, 14]},
  13 => {"action" => "",
    "form" => "Voter Record Update",
    "desc" => "geton",
    "trans" => [100, 14]},
  14 => {"action" => "",
    "form" => "Voter Record Update",
    "desc" => "mail",
    "trans" => [95, 15, 11]},
  15 => {"action" => "match",
    "form" => "Voter Record Update",
    "desc" => "match",
    "trans" => [96, 16, 11]},
  16 => {"action" => "",
    "form" => "Voter Record Update",
    "desc" => "review",
    "leo" => "Leonidas VRU",
    "trans" => [@approval_vru, 17, 18]},
  17 => {"action" => "approve",
    "form" => "Voter Record Update",
    "desc" => "approve",
    "leo" => "Leonidas VRU",
    "trans" => [100, 19]},
  18 => {"action" => "reject",
    "form" => "Voter Record Update",
    "desc" => "reject",
    "leo" => "Leonidas VRU",
    "note" => "wrong address VRU",
    "trans" => [100, 11]},

  19 => {"action" => "",
    "desc" => "is UOCAVA?",
    "trans" => ["UOCAVA", 20, 40]},

  20 => {"action" => "",
    "desc" => "voting?20",
    "trans" => [98, 21, -1]},
  21 => {"action" => "identify",
    "desc" => "online-id21",
    "trans" => [100, 22]},
  22 => {"action" => "start",
    "form" => "Absentee Request",
    "desc" => "start22",
    "trans" => [100, 23]},
  23 => {"action" => "",
    "form" => "Absentee Request",
    "desc" => "finish23",
    "trans" => [95, 24, 25]},
  24 => {"action" => "complete",
    "form" => "Absentee Request",
    "desc" => "complete24",
    "trans" => [100, 27]},
  25 => {"action" => "discard",
    "form" => "Absentee Request",
    "desc" => "discard25",
    "trans" => [100, 20]},
  27 => {"action" => "match",
    "form" => "Absentee Request",
    "desc" => "review27",
    "leo" => "Leonidas AR",
    "trans" => [@approval_ar, 28, 29]},
  28 => {"action" => "approve",
    "form" => "Absentee Request",
    "desc" => "approve28",
    "leo" => "Leonidas AR",
    "trans" => ['UOCAVA', 31, 80]},
  29 => {"action" => "reject",
    "form" => "Absentee Request",
    "desc" => "reject29",
    "leo" => "Leonidas AR",
    "note" => "not signed AR",
    "trans" => [100, 20]},
  
  30 => {"action" => "",
    "desc" => "voting?",
    "trans" => [98, 31, -1]},
  31 => {"action" => "identify",
    "desc" => "online id",
    "trans" => [100, 32]},
  32 => {"action" => "start",
    "form" => "Absentee Ballot",
    "desc" => "start",
    "trans" => [100, 33]},
  33 => {"action" => "",
    "form" => "Absentee Ballot",
    "desc" => "finish",
    "trans" => [95, 34, 35]},
  34 => {"action" => "complete",
    "form" => "Absentee Ballot",
    "desc" => "complete",
    "trans" => [100, 36]},
  35 => {"action" => "discard",
    "form" => "Absentee Ballot",
    "desc" => "discard",
    "trans" => [100, 30]},
  36 => {"action" => "submit",
    "form" => "Absentee Ballot",
    "desc" => "submit",
    "trans" => [100, 37]},
  37 => {"action" => "match",
    "form" => "Absentee Ballot",
    "desc" => "review",
    "leo" => "Leonidas AB",
    "trans" => [@approval_ab, 38, 39]},
  38 => {"action" => "approve",
    "form" => "Absentee Ballot",
    "desc" => "approve",
    "leo" => "Leonidas AB",
    "trans" => [100, -1]},
  39 => {"action" => "reject",
    "form" => "Absentee Ballot",
    "desc" => "reject",
    "leo" => "Leonidas AB",
    "note" => "illegible AB",
    "trans" => [100, -1]},
  
  40 => {"action" => "",
    "desc" => "voting?",
    "trans" => [100, 41, -1]},
  41 => {"action" => "",
    "desc" => "ballotReg?",
    "trans" => [70, 50, 42]},
  42 => {"action" => "",
    "desc" => "ballotAB?",
    "trans" => [20, 60, 70]},

  50 => {"action" => "identify",
    "form" => "Poll Book Entry",
    "desc" => "id at polls",
    "trans" => [100, -1]},

  60 => {"action" => "",
    "form" => "Poll Book Entry",
    "desc" => "vote provisional",
    "trans" => [100, 67]},
  67 => {"action" => "match",
    "form" => "Provisional Ballot",
    "desc" => "review",
    "leo" => "Leonidas PB",
    "trans" => [@approval_pb, 68, 69]},
  68 => {"action" => "approve",
    "form" => "Provisional Ballot",
    "desc" => "approve",
    "leo" => "Leonidas PB",
    "trans" => [100, -1]},
  69 => {"action" => "reject",
    "form" => "Provisional Ballot",
    "desc" => "reject",
    "leo" => "Leonidas PB",
    "note" => "wrong PB",
    "trans" => [100, -1]},

  70 => {"action" => "",
    "form" => "Absentee Request",
    "desc" => "vote absentee70",
    "trans" => [50, 21, 77]},
  77 => {"action" => "match",
    "form" => "Absentee Request",
    "desc" => "review77",
    "leo" => "Leonidas PB",
    "trans" => [@approval_ar, 78, 79]},
  78 => {"action" => "approve",
    "form" => "Absentee Request",
    "desc" => "approve78",
    "leo" => "Leonidas PB",
    "trans" => [100, 80]},
  79 => {"action" => "reject",
    "form" => "Absentee Request",
    "desc" => "reject79",
    "leo" => "Leonidas PB",
    "note" => "wrong PB",
    "trans" => [100, -1]},

  80 => {"action" => "",
    "form" => "Absentee Ballot",
    "desc" => "vote absentee",
    "trans" => [50, 31, 87]},
  87 => {"action" => "match",
    "form" => "Absentee Ballot",
    "desc" => "review",
    "leo" => "Leonidas AB",
    "trans" => [@approval_ab, 88, 89]},
  88 => {"action" => "approve",
    "form" => "Absentee Ballot",
    "desc" => "approve",
    "leo" => "Leonidas AB",
    "trans" => [100, -1]},
  89 => {"action" => "reject",
    "form" => "Absentee Ballot",
    "desc" => "reject",
    "leo" => "Leonidas AB",
    "note" => "wrong AB",
    "trans" => [100, -1]},

  1000 => {"action" => "",
    "form" => "",
    "desc" => "stop",
    "trans" => [100, -1]}
}

@voterStates = Hash.new { |h, k| h[k] = { } }

@nvoters = 10
@vstart = 0
@daycount = 1
@debug = false
@cvtrs = 0
@dvtrs = 0

def notDone()
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStates[vname]
    vstaten = vstate["state"]
    return true if vstaten >= 0
  end
  return false
end

def genVoterStatus()
  (1..@nvoters).each do |n| 
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    @voterStates[vname] = {"state" => 00, "actions" => []}
    @voterStates[vname]["vtype"] = "UOCAVA" if rand(100) < 25
  end
end

def transVoterStatus()
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStates[vname]
    vstaten = vstate["state"]
    vactions = vstate["actions"]
    (vstate["state"], vactions) = stateTrans(vname, vstaten, vactions)
  end
end

def extractVTR(voter, state, n)
  "voter:"+voter+
    ";action:"+state["action"]+
    (state.keys.include?("form") ? ";form:"+state["form"] : "")+
    (state.keys.include?("leo") ? ";leo:"+state["leo"] : "")+
    ";note:"+"("+n.to_s+")"+(state.keys.include?("note") ? " "+state["note"] : "")
end

def stateTrans(vname, vstaten, vactions)
  return [vstaten, vactions] if vstaten < 0
  error("Unknown state: "+vstaten.to_s) unless @states.keys.include?(vstaten)
  newstate = @states[vstaten]
  if false
    action = newstate["action"]+"."+newstate["desc"]
  elsif newstate["action"].length > 0
    action = extractVTR(vname, newstate, vstaten)
    @cvtrs += 1
  end
  trans = newstate["trans"]
  percentage = trans[0]
  state_yes = trans[1]
  state_no = (trans.length > 2 ? trans[2] : -1)
  if percentage == 'UOCAVA'
    if newstate.keys.include?("vtype")
      staten = state_yes
    else
      staten = state_no
    end
  else
    if percentage >= 100
      staten = state_yes
    elsif rand(100) <= percentage
      staten = state_yes
    else
      staten = state_no
    end
  end
  vactions.push(action) if action
  return [staten, action]
end

def error(msg)
  print "**ERROR** "+msg+"\n"
  exit(1)
end

def dumpVoterStatus(datime)
  text = ""
  (1..@nvoters).each do |n|
    vstart = n + @vstart
    vname = "v"+vstart.to_s
    vstate = @voterStates[vname]
    if vstate['actions'].length > 0
      @dvtrs += 1
      text += dumpVoterStatum(vstate['actions'].shift, datime,
                             vstate.keys.include?('vtype'))
      datime = incrSeconds(datime)
      
    end
  end
  return [text, datime]
end

def incrSeconds(datime)
  if (datime =~ /(\d\d)Z/)
    oldsecs = $1
    secs = (oldsecs.to_i+1)%60
    if secs < 10
      secstr = "0"+secs.to_s
    else
      secstr = secs.to_s
    end
    datime=datime.sub("#{oldsecs}Z","#{secstr}Z")
  end
  return datime
end

def dumpVoterStatum(cstring, datime, vtype)
  text = "  <voterTransactionRecord>\n    <date>"+datime+"</date>\n"
  cstring.split(';').each do |s|
    (field, value) = s.split(':')
    if field == "voter"
      text += "    <voter>"+value+"</voter>\n"
      text += "    <vtype>UOCAVA</vtype>\n" if vtype
    elsif field == "form"
      text += "    <"+field+"><type>"+value+"</type></"+field+">\n"
    else
      text += "    <"+field+">"+value+"</"+field+">\n"
    end
  end
  text += "  </voterTransactionRecord>\n"
end

def printFile(text, m, n, flag = false)
  filename="testvtl/test_vtl"
  if flag
    filename += ".xml"
  else
    filename += "_"+m.to_s+"_"+(n < 10 ? "0"+n.to_s : n.to_s)+".xml"
  end
  print "Printing Log to File: "+filename+"\n"
  f = File.open(filename,"w")
  f.print text
  f.close
end

def makeTransLog(text, datime)
  uniq = @daycount*100
  @daycount += 1
  header  = "  <header>\n"
  header += "    <origin>Test</origin>\n"
  header += "    <originUniq>"+uniq.to_s+"</originUniq>\n"
  header += "    <date>"+datime+"</date>\n"
  header += "  </header>\n"
  return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+
    "<voterTransactionLog>\n"+header+text+"</voterTransactionLog>\n"
end

def printVoterStatus()
  @voterStates.keys.each do |v|
    print v+": "+@voterStates[v].to_s+"\n"
  end
end

begin
  if ARGV.length > 0
    @nvoters = ARGV.shift.to_i
  end
  if ARGV.length > 0
    @vstart = ARGV.shift.to_i
  end
  genVoterStatus()
  if @debug
    printVoterStatus()
  end
  count = 1
  while (count < 100 and notDone())
    transVoterStatus()
    if @debug
      printVoterStatus()
    end
    count += 1
  end
  print "# Voters: "+@nvoters.to_s+"\n"
  print "# Iterations: "+count.to_s+"\n"
  print "# VTRs: "+@cvtrs.to_s+"\n"
  allvtrs = ""
  day = 1
  datime = "2012-05-01T10:10:00Z"
  predatime = "2012-0"
  month = 5
  (vtrs, datime) = dumpVoterStatus(datime)
  while (vtrs.length > 0)
    allvtrs += vtrs
    printFile(makeTransLog(vtrs,datime),month,day)
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
    (vtrs, datime) = dumpVoterStatus(datime)
  end
  printFile(makeTransLog(allvtrs,datime),0,0,flag=true)
end
