class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  # Sends the #xml string as a attachment file with the given #filename.
  def send_xml(filename, xml)
    send_data xml,
      filename:     filename,
      type:         'text/xml; charset=UTF-8;',
      disposition:  'attachment;'
  end

  def current_user!
    unless user_signed_in?
      flash[:alert] = "This area is restricted to logged-in users only."
      authenticate_user!
    end
    current_user
  end

  def admin_user!
    unless user_signed_in? && current_user.is_admin
      flash[:alert] = "This area is restricted to logged-in administrators only."
      authenticate_admin_user!
    end
    current_user
  end

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.admin?
      flash[:alert] = "This area is restricted to administrators only."
      redirect_to root_path
    end
  end
 
  def current_admin_user
    return nil if user_signed_in? && !current_user.admin?
    current_user
  end

  def voter_report_find(n, eid)
    unless ar = AnalyticReport.find{|ar|ar.num==n && ar.election_id==eid}
      raise Exception, "No #"+n.to_s+" report found for election id: "+eid
    end
    return ar
  end

  def voter_report_save(vhash, n, eid)
    ar = voter_report_find(n, eid)
    ar.set_data(vhash)
  end

  def voter_report_fetch(n, e)
    eid = e.id
    ar = voter_report_find(n, eid)
    return false if ar.data == ""
    return false if ar.updated_at < e.updated_at
    return ar.get_data
  end

  def voter_record_report_save(vhash, e)
    eid = e.id
    [2, 3, 4].each do |n|
      if ar = voter_report_find(n, eid)
        ar.data = ""
        ar.save
      end
    end
    return voter_report_save(vhash, 1, eid)
  end
  
  def voter_record_report_fetch(e)
    return voter_report_fetch(1, e)
  end
  
  def voter_record_reporx_save(vhash, e)
    eid = e.id
    return voter_report_save(vhash, 4, eid)
  end

  def voter_record_reporx_fetch(e)
    return voter_report_fetch(4, e)
  end

  def voter_record_report_init()
    vhash = Hash.new {}
    %w(tot das dda ddo dgf dgm dpd dpo dpr dua dul dum duo duu).each do |k|
      vhash[k] = 0
    end
    %w(dnw ngf ngm npd npo npr).each do |k|
      vhash[k] = 0
    end
    %w(totp ddop dump duop).each do |k|
      vhash[k] = 0
    end
    return vhash
  end

  def voter_record_report_update(vhash, vr, e)
    report_demographic(vr, vhash)
    vhash['das'] += 1 if vr.absentee_status?
    if vr.new?(e)
      vhash['dnw'] += 1
      vhash['ngm'] += 1 if vr.male?
      vhash['ngf'] += 1 if vr.female?
      vhash['npd'] += 1 if vr.party_democratic?
      vhash['npr'] += 1 if vr.party_republican?
      vhash['npo'] += 1 if vr.party_other?
    else
      vhash['totp'] += 1
      vhash['ddop'] += 1 unless vr.military? or vr.overseas?
      vhash['dump'] += 1 if vr.military?
      vhash['duop'] += 1 if vr.overseas?
    end
    if vr.uocava?
      vhash['duu'] += 1
      vhash['dum'] += 1 if vr.military?
      vhash['duo'] += 1 if vr.overseas?
      vhash['dul'] += 1 if vr.absentee_ulapsed?
      vhash['dua'] += 1 unless vr.absentee_ulapsed?
    else
      vhash['ddo'] += 1
      vhash['dda'] += 1 if vr.absentee_status?
    end
  end

  def voter_record_report_finalize(vhash)
    report_percentage(vhash, %w(dum duo), vhash['duu'])
    report_percentage(vhash, %w(dgm dgf dpd dpr dpo), vhash['tot'])
    report_percentage(vhash, %w(ngf ngm npd npo npr), vhash['dnw'])
  end

  def report_percentage(vhash, keys, total)
    keys.each{|k| vhash[k+'_p'] = percent(vhash[k],total) }
  end
      
  def report_demographic(vr, vhash)
    vhash['tot'] += 1
    vhash['dgm'] += 1 if vr.male?
    vhash['dgf'] += 1 if vr.female?
    vhash['dpd'] += 1 if vr.party_democratic?
    vhash['dpr'] += 1 if vr.party_republican?
    vhash['dpo'] += 1 if vr.party_other?
  end

  def voter_participating_report_save(vhash, e)
    return voter_report_save(vhash, 2, e.id)
  end

  def voter_participating_report_fetch(e)
    return voter_report_fetch(2, e)
  end

  def voter_uocava_report_save(vhash, e)
    return voter_report_save(vhash, 3, e.id)
  end

  def voter_uocava_report_fetch(e)
    return voter_report_fetch(3, e)
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
    #return extra(x,y)+(y==0 ? "0%" : ((100*x)/y).round.to_s+"%")
    return extra(x,y)+(y==0 ? "0%" : sprintf("%.1f",((100*x.to_f)/y.to_f))+"%")
  end
  
  def percent_parens(x,y)
    return "("+percent(x,y)+")"
  end

  def percent_forms(x,y)
    return "("+percent(x,y)+" of forms generated)"
  end

end
