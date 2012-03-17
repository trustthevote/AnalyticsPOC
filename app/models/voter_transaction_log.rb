class VoterTransactionLog < ActiveRecord::Base
  validates_presence_of :origin
  validates_presence_of :datime
  validates_uniqueness_of :origin, :scope => [:datime, :origin_uniq],
                                   :message => "and date/time are exact duplicates of pre-existing log"
  belongs_to :election
  has_many :voter_transaction_records, :dependent => :destroy

  def to_voter_xml() 
    xml = "<voterTransactionLog>" + "<header>" +
      "<origin>"+self.origin+"</origin>" +
      ((self.origin_uniq and self.origin_uniq.length > 0) ?
       "<originUniq>"+self.origin_uniq+"</originUniq>" : "") +
      "<date>"+self.datime.xmlschema+"</date>" + "</header>"
    self.voter_transaction_records.each do |vtr|
      xml += vtr.to_voter_xml()
    end
    return xml + "</voterTransactionLog>"
  end

end
