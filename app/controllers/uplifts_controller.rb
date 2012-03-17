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
    @uplift_xml = ""
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
    self.validateFile("public/uploads/"+self.uplift_file)
  rescue CarrierWave::IntegrityError => e
    @uplift_msg = "Invalid XML file name: "+self.uplift_file
    render :uplift
  rescue => e
    @uplift_msg = "Should't happen #1: "+e.message # JVC temp
    render :uplift
  end

  def validateFile(document_path)
    #use valid? on both objects
    unless (schema = self.readXMLSchema("public/xml/VTL.xsd"))
      return
    end
    unless (document = self.readXMLDocument(document_path))
      return
    end
    errors = schema.validate(document)
    if (errors.length > 0)
      @uplift_err += "Validation Errors: "      
      errors.each { |e| @uplift_err += e.message }
      render :uplift
    else
      if self.finalizeVTL(document)
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

  def contentOrEmptyStr(xml)
    if xml
      return xml.content
    else
      return ""
    end
  end

  def mungeForm(type1, type2, name, number)
    if type1.empty?
      return ""
    end
    if type2.empty?
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

  def finalizeVTL(xml)
    origin = self.contentOrEmptyStr(xml % 'header/origin')
    ouniq = self.contentOrEmptyStr(xml % 'header/originUniq')
    logdate = self.contentOrEmptyStr(xml % 'header/date')
    locale = ""
    elec_id = Selection.all[0].eid
    vtl = VoterTransactionLog.new(:origin => origin,  :origin_uniq => ouniq,
                                  :datime => logdate, :locale => locale,
                                  :election_id => elec_id)
    unless (vtl.save)
      vtl.errors.full_messages.each do |e|
        @uplift_err += " "+e
      end
      return false
    end
    (xml / 'voterTransactionRecord').each do |vtr|
      voter = self.contentOrEmptyStr(vtr % 'voter')
      vtype = self.contentOrEmptyStr(vtr % 'vtype')
      datime = self.contentOrEmptyStr(vtr % 'date')
      action = self.contentOrEmptyStr(vtr % 'action')
      leo = self.contentOrEmptyStr(vtr % 'leo')
      note = self.contentOrEmptyStr(vtr % 'note')
      type1 = ""
      type2 = ""
      name = ""
      number = ""
      first = 0
      if (node = vtr % 'form')
        (node / 'type').each do |type|
          if (first == 0)
            type1 = type.content
            first = 1
          elsif (first == 1)
            type2 = type.content
            first = 2
          end
        end
        name = self.contentOrEmptyStr(node % 'name')
        number = self.contentOrEmptyStr(node % 'number')
        form = mungeForm(type1, type2, name, number)
      end
      vtr = VoterTransactionRecord.new(:datime => datime, :voter => voter,
                                       :vtype => vtype, :action => action,
                                       :form => form, :leo => leo,:note => note,
                                       :voter_transaction_log_id => vtl.id)
      unless (vtr.save)
        vtr.errors.full_messages.each do |e|
          @uplift_err += " "+e
        end
        return false
      end
    end
    vtl.save
    #@uplift_xml = vtl.to_voter_xml()
    return true
  end

 # from http://vitobotta.com/more-methods-format-beautify-ruby-output-console-logs/

  def xp(xml_text)
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

  def readXMLSchema(file)
    return Nokogiri::XML::Schema(File.read(file))
  rescue => e
    @uplift_err += "Shouldn't happen #3, invalid built-in schema. "+e.message
    render :uplift
    return false
  end
  
  def readXMLDocument(file)
    return Nokogiri::XML(File.open(file))
  rescue => e
    @uplift_err += "Invalid File format: "+e.message
    render :uplift
    return false
  end

end
