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

  def voter_record_report_find(eid)
    unless avr = AnalyticReport.find{|ar|ar.election_id==eid&&ar.num==1}
      raise Exception, "No Voter Record report found for election with id: "+eid
    end
    return avr
  end

  def voter_record_report_save(avhash, eid)
    avr = self.voter_record_report_find(eid)
    avr.set_data(avhash)
  end

  def voter_record_report_fetch(eid)
    avr = self.voter_record_report_find(eid)
    if avr.data == ""
      return false
    else
      return avr.get_data
    end
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

end
