class Election < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :day
  has_many :voter_transaction_logs, :dependent => :destroy
  has_many :voters, :dependent => :destroy

  def log_add(vtl)
    if self.elogs.blank?
      self.elogs = "1,1"
    else
      self.elogs = (self.logs_num+1).to_s+","+(self.logs_max+1).to_s
    end
    self.erecords = (self.erecords.to_i+vtl.voter_transaction_records.length).to_s
    self.evoters = self.uvoters.to_s
  end

  def log_del(vtl)
    vtl.delete_archive_file
    self.elogs = (self.logs_num-1).to_s+","+self.logs_max.to_s
    self.erecords = (self.erecords.to_i-vtl.voter_transaction_records.length).to_s
    self.evoters = self.nvoters(vtl).to_s
  end

  def logs_num
    return 0 if self.elogs.blank?
    num, max = self.elogs.split(',')
    return num.to_i
  end

  def logs_max
    return 0 if self.elogs.blank?
    num, max = self.elogs.split(',')
    return max.to_i
    end

  def records_num
    return 0 if self.erecords.blank?
    return self.erecords.to_i
  end

  def voters_num
    return 0 if self.evoters.blank?
    return self.evoters.to_i
  end

  def nrecords()
    n = self.voter_transaction_logs.inject(0) {|n,vtl| n+vtl.voter_transaction_records.length}
    return n
  end

  def uvoters() # number of unique voters
    uvs = []
    self.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        uvs.push(vtr.vname) unless uvs.include?(vtr.vname)
      end
    end
    return uvs.length      
  end
  
  def nvoters(dvtl) # number of unique voters
    uvs = []
    self.voter_transaction_logs.each do |vtl|
      unless vtl == dvtl
        vtl.voter_transaction_records.each do |vtr|
          uvs.push(vtr.vname) unless uvs.include?(vtr.vname)
        end
      end
    end
    return uvs.length      
  end
  
end
