class VoterTransactionLog < ActiveRecord::Base
  validates_presence_of :origin
  validates_presence_of :datime
  validates_uniqueness_of :origin, :scope => [:datime, :origin_uniq],
                                   :message => "(+uniq) and daytime duplicated in pre-existing log file."
  belongs_to :election
  has_many :voter_transaction_records, :dependent => :destroy

  def archive
    input_file = self.file_name
    eid = self.election_id
    e = Election.find(eid)
    unless e
      raise Exception, "Election not found during archive operation"
    end
    unless (defined?(e.nalllogs) && e.nalllogs.is_a?(Integer))
      e.nalllogs = e.voter_transaction_logs.length+1 
    end #JVC invalid in presence of deletes
    # Either Election needs to hold total number of election logs seen to
    # date, or it needs to keep the actual list of archived log files, AND, a
    # log file delete needs to delete the archives file (and maybe the uloads
    # file?) 
    path = 'public/archives/e'+eid.to_s
    file = "vtl_"+e.nalllogs.to_s+".xml"
    unless File.directory?(path)
      unless Dir.mkdir(path)
        raise Exception, "Cannot create directory: "+path
      end
    end
    archive_path = path+"/"+file
    self.archive_name = archive_path
    upload_path = 'public/uploads/'+self.file_name
    FileUtils.copy(upload_path,archive_path)
    e.nalllogs = e.nalllogs+1
    e.save
  end

end
