class VoterTransactionLog < ActiveRecord::Base
  validates_presence_of :origin
  validates_presence_of :datime
  validates_uniqueness_of :origin, :scope => [:datime, :origin_uniq],
                                   :message => "of log file and exact daytime identical to pre-existing log file, duplicate log presumed, rejected."
  belongs_to :election
  has_many :voter_transaction_records, :dependent => :destroy

  def delete_archive_file
    File.delete(self.archive_name) if File.exists?(self.archive_name)
  end
  
  def create_archive_file
    eid = self.election_id
    unless (e = Election.find(eid))
      raise Exception, "Election not found during file archive operation"
    end
    unless File.directory?(path = 'public/archives')
      raise Exception, "No archive directory: "+path
    end
    self.archive_name = path+"/"+"e"+eid.to_s+"_vtl_"+e.logs_max.to_s+".xml"
    FileUtils.copy('public/uploads/'+self.file_name, self.archive_name)
    e.log_add(self)
    e.save
  end

end
