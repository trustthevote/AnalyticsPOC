require 'nokogiri'
require 'csv'

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
    if type1.blank?
      return ""
    elsif type2.blank?
      if name.blank? and number.blank?
        return type1
      else
        return type1+" | "+(name.blank? ? " | " : " | "+name)+
          (number.blank? ? "" : " | "+number)
      end
    elsif name.blank? and number.blank?
      return type1+" | "+type2
    else
      return type1+" | "+type2+(name.blank? ? " | " : " | "+name)+
        (number.blank? ? "" : " | "+number)
    end
  end

  def upliftVoter(vname, vtype, eid)
    voter = Voter.find_or_create_by_vuniq(vname+"_"+eid.to_s) do |v|
      if v.vname.blank?
        v.vname = vname
        v.vtype = vtype
        v.voted, v.vreject, v.vonline, v.vnew = false, false, false, false
        v.vform = ""
        v.vnote = ""
        v.vgender = ""
        v.vparty = ""
        v.vother = ""
        v.vstatus = ""
        v.vupdate = ""
        v.vabsreq = ""
        v.election_id = eid
        #fetchVoterFields(v)
      end
    end
    return voter
  end

  def fetchVoterFields(v)
    VoterRecord.all.each do |vr|
      if v.vname == vr.vname
        v.vgender = vr.gender
        v.vparty = vr.party
        v.vother = vr.other
        v.vstatus = vr.status
        return
      end
    end
  end

  def updateVoterFieldsFromRecord(vr)
    Voter.all.each do |v|
      if v.vname == vr.vname
        v.vgender = vr.gender
        v.vparty = vr.party
        v.vother = vr.other
        v.vstatus = vr.status
        v.save
        return
      end
    end
  end

  def syncVoter(voter, vtr)
    voter.vnew = true if (vtr.action == 'approve' &&
                          vtr.form =~ /Voter Registration/)
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
        voter.vnote = vtr.note
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
        voter.vnote = vtr.note
        voter.vform = "Provisional"
      end
    elsif (vtr.form =~ /Record Update/)
      if (vtr.action == 'approve')
        voter.vupdate = 'approve'
      elsif (vtr.action == 'reject')
        voter.vupdate = 'reject'
      else
        voter.vupdate = 'try' unless voter.vupdate == 'approve'
      end
    elsif (vtr.form =~ /Absentee Request/)
      if (vtr.action == 'approve')
        voter.vabsreq = 'approve'
      elsif (vtr.action == 'reject')
        voter.vabsreq = 'reject'
      else
        voter.vabsreq = 'try' unless voter.vabsreq == 'approve'
      end
    end
    if ["identify","start","discard","complete","submit"].include?(vtr.action)
      voter.vonline = true
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
                                  :archive_name => '',
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
    vtl.create_archive_file
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

  def upliftVoterRecords(csv_file, eid)
    unless (csv_file =~ /\.csv$/i)
      @uplift_err = "Invalid file type, only .CSV files accepted: "+csv_file.to_s
      render :uplift
      return false
    end
    if self.csv_import(csv_file)
      voter_records_file_new('public/uploads/',self.uplift_file)
      redirect_to '/voter_records', {:params=>{:id=>eid}}
      return true
    end
  end

  def csv_import(file)
    unless csv = IO.readlines(file)
      @uplift_err = "File not readable: "+file
      render :uplift
      return false
    end
    unless csv[0] =~ /^Voter,Type,Gender,Party/
      @uplift_err = "Invalid header line of CSV file: "+csv[0]
      render :uplift
      return false
    end
    vrhash = Hash.new {}
    csv.shift
    csv.each do |row|
      if row =~ /^(\w+),(\w+),(\w+),(\w+),(\w*),(\w*)/
        vr=VoterRecord.new(:vname=>$1, :vtype=>$2, :gender=>$3, :party=>$4,
                           :other=>$5, :status=>$6)
        vrhash[vr.vname] = [vr.gender, vr.party, vr.other, vr.status]
        vr.save
      elsif row =~ /^(\w+),(\w+),(\w+),(\w+),(\w*)/
        vr=VoterRecord.new(:vname=>$1, :vtype=>$2, :gender=>$3, :party=>$4,
                           :other=>$5, :status=>"")
        vrhash[vr.vname] = [vr.gender, vr.party, vr.other, vr.status]
        vr.save
      elsif row =~ /^(\w+),(\w+),(\w+),(\w+)/
        vr=VoterRecord.new(:vname=>$1, :vtype=>$2, :gender=>$3, :party=>$4,
                           :other=>"", :status=>"")
        vrhash[vr.vname] = [vr.gender, vr.party, vr.other, vr.status]
        vr.save
      else
        @uplift_err = "Invalid row in CSV file: "+row
        render :uplift
        return false
      end
    end
    Voter.all.each do |v|
      gender, party, other, status = "", "", "", ""
      if vrhash.keys.include?(v.vname)
        gender, party, other, status = vrhash[v.vname]
      end
      if (v.vgender != gender || v.vparty != party ||
          v.vother != other || v.vstatus != status)
        v.vgender, v.vparty, v.vother, v.vstatus = gender, party, other, status
        v.save
      end
    end
    return true
  end
  
  def voter_records_file_new (fupath, file)
    path = 'public/records'
    unless File.directory?(path) || FileUtils.mkdir(path)
      raise Exception, "No voter records repository: "+path
    end
    files = Array.new
    Dir.new(path).entries.each do |f|
      if f =~ /\.csv$/i
        unless File.delete(path+"/"+f)
          raise Exception, "Cannot delete old voter records file: "+f
        end
      end
    end
    FileUtils.copy(fupath+"/"+file, path+"/"+file)
    unless File.exists?(path+"/"+file)
      raise Exception, "Cannot store voter records file: "+file
    end
  end

end
