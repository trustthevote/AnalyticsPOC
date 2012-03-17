class VoterTransactionRecord < ActiveRecord::Base
  validates_presence_of :voter
  validates_presence_of :datime
  validates_presence_of :action
  belongs_to :voter_transaction_log

  def to_voter_xml_form(form)
    (type1, type2, name, number) = form.split(' | ')
    "<form>" +
      "<type>"+type1+"</type>" +
      ((type2 and type2.length > 0) ?
       "<type>"+type2+"</type>" : "") +
      ((name and name.length > 0) ?
       "<name>"+name+"</name>" : "") +
      ((number and number.length > 0) ?
       "<number>"+number+"</number>" : "") +
        "</form>"
  end
  
  def to_voter_xml()
    "<voterTransactionRecord>\n" +
      "<voter>"+self.voter+"</voter>&#x000A;" +
      ((self.vtype and self.vtype.length > 0) ?
       "<vtype>"+self.vtype+"</vtype>" : "") +
      "<date>"+self.datime.xmlschema+"</date>" +
      "<action>"+self.action+"</action>" +
      ((self.form and self.form.length > 0) ?
       (to_voter_xml_form form) : "") +
      ((leo and leo.length > 0) ?
       "<leo>"+self.leo+"</leo>" : "") +
      ((note and note.length > 0) ?
       "<note>"+self.note+"</note>" : "") +
      "</voterTransactionRecord>"
    end

  def to_voter_xml_spaced_form(form, vtr)
    (type1, type2, name, number) = form.split(' | ')
    vtr.append("..<form>")
    vtr.append("....<type>"+type1+"</type>")
    if (type2 and type2.length > 0)
      vtr.append("....<type>"+type2+"</type>")
    end
    if (name and name.length > 0)
      vtr.append("....<name>"+name+"</name>")
    end
    if (number and number.length > 0)
      vtr.append("....<number>"+number+"</number>")
    end
    return vtr.append("..</form>")
  end
  
  def to_voter_xml_spaced()
    vtr = ["<voterTransactionRecord>",
           "..<voter>"+self.voter+"</voter>"]
    if (self.vtype and self.vtype.length > 0)
      vtr.append("..<vtype>"+self.vtype+"</vtype>")
    end
    vtr.append("..<date>"+self.datime.xmlschema+"</date>")
    vtr.append("..<action>"+self.action+"</action>")
    if (self.form and self.form.length > 0)
      vtr=to_voter_xml_spaced_form(self.form, vtr)
    end
    if (leo and leo.length > 0)
      vtr.append("..<leo>"+self.leo+"</leo>")
    end
    if (note and note.length > 0)
      vtr.append("..<note>"+self.note+"</note>")
    end
    return vtr.append("</voterTransactionRecord>")
  end

end
