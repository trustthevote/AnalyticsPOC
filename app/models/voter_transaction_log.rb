class VoterTransactionLog < ActiveRecord::Base
  validates_presence_of :origin
  validates_presence_of :datime
  validates_uniqueness_of :origin, :scope => [:datime, :origin_uniq],
                                   :message => "and date indicate this log file is a duplicate (it already appears under the current election event) and thus it has been rejected."
  belongs_to :election
  has_many :voter_transaction_records, :dependent => :destroy

  def arecords()
    return self.voter_transaction_records.inject(0){|m,vtr|m+(vtr.form=~/Absentee\sBallot/?1:0)}
  end

  def urecords()
    return self.voter_transaction_records.inject(0){|m,vtr|m+(vtr.vtype=~/UOCAVA/?1:0)}
  end

  def archived
    if e = Election.find(self.election_id)
      return e.archived
    else
      return true
    end
  end
  
  def delete_archive_file
    File.delete(self.archive_name) if File.exists?(self.archive_name)
  end
  
  def create_archive_file
    eid = self.election_id
    unless (e = Election.find(eid))
      raise Exception, "Election not found during file archive operation"
    end
    apath = 'public/archives'
    unless File.directory?(path = apath) || FileUtils.mkdir(apath)
      raise Exception, "No archive directory: "+apath
    end
    self.archive_name = apath+"/"+"e"+eid.to_s+"_vtl_"+e.logs_max.to_s+".xml"
    FileUtils.copy('public/uploads/'+self.file_name, self.archive_name)
    e.log_add(self)
    e.save
  end

  def date
    return self.datime.strftime("%B %-d, %Y")
  end

end
