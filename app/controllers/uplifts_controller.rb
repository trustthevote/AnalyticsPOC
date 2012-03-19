require 'nokogiri'

class UpliftsController < ApplicationController

  attr_accessor :uplift_file

  def uplift
    if ((Selection.all.length == 0) || (Selection.all[0].eid == nil) ||
        (! Election.all.any? {|e| e.id == Selection.all[0].eid}))
      @uplift_msg = "Error: must select an Election before uploading logs."
      render :uplift
      return
    end
    @uplift_msg = ""
    @uplift_err = ""
    unless params['file']
      @uplift_msg = "Error: choose file name"
      render :uplift
      return
    end
    self.uplift_file = params['file'].original_filename
    uploader = LogfileUploader.new
    post = uploader.store!( params['file'] )
    @uplift_msg = "Uploaded: " + self.uplift_file
    self.upliftValidate("public/uploads/"+self.uplift_file)
  rescue CarrierWave::IntegrityError => e
    @uplift_msg = "Invalid XML file name: "+self.uplift_file
    render :uplift
  rescue => e
    @uplift_msg = "Should't happen #1: "+e.message # JVC temp
    render :uplift
  end

  def upliftReadXMLSchema(file)
    return Nokogiri::XML::Schema(File.read(file))
  rescue => e
    @uplift_err += "Shouldn't happen #3, invalid built-in schema. "+e.message
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

  def upliftValidate(document_path)
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
      if self.upliftFinalizeLog(document)
        if (@uplift_err == "")
          @uplift_err = "Validation: OK"
        end
        render 'pages/front'
      else
        render :uplift
      end
    end
  rescue => e
    @uplift_err += "Should't happen #2: "+e.message # JVC temp
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

  def upliftFinalizeLog(xml)
    origin = self.upliftExtractContent(xml % 'header/origin')
    ouniq = self.upliftExtractContent(xml % 'header/originUniq')
    logdate = self.upliftExtractContent(xml % 'header/date')
    vtl = VoterTransactionLog.new(:origin => origin,  :origin_uniq => ouniq,
                                  :datime => logdate, :locale => locale,
                                  :election_id => Selection.all[0].eid)
    unless (vtl.save)
      vtl.errors.full_messages.each { |e| @uplift_err += " "+e }
      return false
    end
    (xml / 'voterTransactionRecord').each do |vtr|
      voter = self.upliftExtractContent(vtr % 'voter')
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
      vtr = VoterTransactionRecord.new(:datime => datime, :voter => voter,
                                       :vtype => vtype, :action => action,
                                       :form => form, :leo => leo,:note => note,
                                       :voter_transaction_log_id => vtl.id)
      unless (vtr.save)
        vtl.errors.full_messages.each { |e| @uplift_err += " "+e }
        return false
      end
    end
    vtl.save
    #@uplift_xml = vtl.to_voter_xml()
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

end