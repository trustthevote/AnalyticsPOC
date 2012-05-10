require 'nokogiri'

class UpliftsController < ApplicationController

  attr_accessor :uplift_file

  def uplift
    startime = DateTime.now
    eid = params[:eid]
    @election = Election.find(eid) unless defined?(@election)
    @uplift_msg = ""
    @uplift_err = ""
    @uplift_csv = ""
    unless params['file']
      @uplift_msg = "Error: choose file name"
      render :uplift
      return
    end
    self.uplift_file = params['file'].original_filename
    uploader = LogfileUploader.new
    post = uploader.store!( params['file'] )
    @uplift_msg = "Uploaded: " + self.uplift_file
    if (params[:uptype] == "vr")
      self.upliftVoterRecords("public/uploads/"+self.uplift_file, eid)
    else
      self.upliftValidate("public/uploads/"+self.uplift_file, eid)
    end
  rescue CarrierWave::IntegrityError => e
    @uplift_msg = "Invalid XML file name: "+self.uplift_file
    render :uplift
  rescue => e
    @uplift_msg = "Shouldn't happen #1: "+e.message # JVC temp
    render :uplift
  end

  def upliftDuration(t1, t2)
    return " ("+t1.to_s+" | "+t2.to_s+")"
    return distance_of_time_in_words(t1, to_time=t2, include_seconds=true)
  end
  
  def upliftReadXMLSchema(file)
    return Nokogiri::XML::Schema(File.read(file))
  rescue => e
    @uplift_err += " Shouldn't happen #3, invalid built-in schema. "+e.message
    render :uplift
    return false
  end
  
  def upliftReadXMLDocument(file)
    return Nokogiri::XML(File.open(file))
  rescue => e
    @uplift_err += "Invalid File format: "+e.message
    render :uplift
    return false
  end

  def upliftValidate(document_path, eid)
    return unless (schema = self.upliftReadXMLSchema("public/xml/VTL.xsd"))
    return unless (document = self.upliftReadXMLDocument(document_path))
    errors = schema.validate(document)
    if (errors.length > 0)
      @uplift_err += "Validation Errors: "      
      errors.each { |e| @uplift_err += e.message }
      if @uplift_err =~ / root\.$/
        errs = @uplift_err.split(' ')
        errs.pop
        errs = errs.push("root <voterTransactionLog>")
        @uplift_err = errs.join(' ')
      end
      render :uplift
    else
      if self.upliftFinalizeLog(document, eid)
        if (@uplift_err == "")
          @uplift_err = "Validation: OK"
        end
        redirect_to '/elections/'+eid.to_s, {:params=>{:id=>eid}}
      else
        render :uplift
      end
    end
  rescue => e
    @uplift_err += " Should't happen #2: "+e.message # JVC temp
  end

  def upliftExtractContent(xml)
    return (xml ? xml.content : "")
  end

  def upliftMungeForm(type1, type2, name, number)
    if type1.empty?
      return ""
    elsif type2.empty?
      if name.empty? and number.empty?
        return type1
      else
        return type1+" | "+(name.empty? ? " | " : " | "+name)+
          (number.empty? ? "" : " | "+number)
      end
    elsif name.empty? and number.empty?
      return type1+" | "+type2
    else
      return type1+" | "+type2+(name.empty? ? " | " : " | "+name)+
        (number.empty? ? "" : " | "+number)
    end
  end

  def upliftVoter(vname, vtype, eid)
    voter = Voter.find_or_create_by_vuniq(vname+"_"+eid.to_s) do |v|
      if v.vname.blank?
        v.vname = vname
        v.vtype = vtype
        v.voted, v.vreject = false, false
        v.vform = ""
        v.vnote = ""
        v.election_id = eid
      end
    end
    return voter
  end

  def syncVoter(voter, vtr)
    if voter.voted
      return
    elsif (vtr.form =~ /Poll Book/)
      voter.voted = true
      voter.vreject = false
      voter.vform = "Regular"
    elsif (vtr.form =~ /Absentee Ballot/)
      if (vtr.action == 'approve')
        voter.voted = true
        voter.vreject = false
        voter.vform = "Absentee"
      elsif (vtr.action == 'reject')
        voter.voted = true
        voter.vreject = true
        voter.vform = "Absentee"
      end
    elsif (vtr.form =~ /Provisional Ballot/)
      if (vtr.action == 'approve')
        voter.voted = true
        voter.vreject = false
        voter.vform = "Provisional"
      elsif (vtr.action == 'reject')
        voter.voted = true
        voter.vreject = true
        voter.vform = "Provisional"
      end
    end
    voter.save
  end

  def upliftFinalizeLog(xml, eid)
    origin = self.upliftExtractContent(xml % 'header/origin')
    ouniq = self.upliftExtractContent(xml % 'header/originUniq')
    logdate = self.upliftExtractContent(xml % 'header/date')
    vtl = VoterTransactionLog.new(:origin => origin,
                                  :origin_uniq => ouniq,
                                  :datime => logdate,
                                  :file_name => self.uplift_file,
                                  :election_id => eid)
    unless (vtl.save)
      @uplift_err = "Error: "
      vtl.errors.full_messages.each { |e| @uplift_err += " "+e }
      return false
    end
    (xml / 'voterTransactionRecord').each do |vtr|
      vname = self.upliftExtractContent(vtr % 'voter')
      vtype = self.upliftExtractContent(vtr % 'vtype')
      datime = self.upliftExtractContent(vtr % 'date')
      action = self.upliftExtractContent(vtr % 'action')
      leo = self.upliftExtractContent(vtr % 'leo')
      note = self.upliftExtractContent(vtr % 'note')
      type1, type2, name, number = "", "", "", ""
      if (node = vtr % 'form')
        (node / 'type').each do |type|
          ((type1 == "") ? type1 = type.content : type2 = type.content )
        end
        name = self.upliftExtractContent(node % 'name')
        number = self.upliftExtractContent(node % 'number')
        form = upliftMungeForm(type1, type2, name, number)
      end
      voter = self.upliftVoter(vname, vtype, eid)
      unless (voter.save)
        voter.errors.full_messages.each { |e| @uplift_err += " "+e }
        return false
      end
      vid = voter.id
      vtr = VoterTransactionRecord.new(:datime => datime,
                                       :vname => vname,
                                       :vtype => vtype,
                                       :action => action,
                                       :form => form,
                                       :leo => leo,
                                       :note => note,
                                       :voter_transaction_log_id => vtl.id,
                                       :voter_id => vid)
      unless (vtr.save)
        vtl.errors.full_messages.each { |e| @uplift_err += " "+e }
        return false
      end
      self.syncVoter(voter, vtr)
    end
    vtl.save
    return true
  end

  # http://vitobotta.com/more-methods-format-beautify-ruby-output-console-logs/

  def upliftXMLpp(xml_text)
    xsl = <<XSL
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
      <xsl:copy-of select="."/>
    </xsl:template>
  </xsl:stylesheet>

XSL

    doc  = Nokogiri::XML(xml_text)
    xslt = Nokogiri::XSLT(xsl)
    out  = xslt.transform(doc)
    puts out.to_xml
  end

  def upliftVoterRecords(document_path, eid)
    unless (document_path =~ /\.csv$/i)
      @uplift_err = "Invalid file type, only .CSV files accepted: "+document_path.to_s
      render :uplift
      return false
    end
    self.save_selection_vr(eid)
    vr = VoterRecord.new(:vname => 'v1',:vtype => 'domestic',
                          :gender => 'M', :party => 'Democratic')
    vr.save
    vr = VoterRecord.new(:vname => 'v2',:vtype => 'domestic',
                          :gender => 'F', :party => 'Republican')
    vr.save
    vr = VoterRecord.new(:vname => 'v3',:vtype => 'UOCAVA',
                          :gender => 'F', :party => 'Green')
    vr.save
    redirect_to '/voter_records', {:params=>{:id=>eid}}
    return true
  end

  def save_selection_vr(eid)
    file = self.uplift_file
    origin = 'Virginia'
    if (Selection.all.length == 0)
      se = Selection.new(:eid => eid, :vr_file => file, :vr_origin => origin)
    else
      se = Selection.all[0]
      se.vr_file = file
      se.vr_origin = origin
    end
    se.save
  end

end
