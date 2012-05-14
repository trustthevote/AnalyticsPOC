class Election < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :day
  has_many :voter_transaction_logs, :dependent => :destroy
  has_many :voters, :dependent => :destroy

  def display()
    return self.name+" "+self.day.strftime("%B %-d, %Y")
  end

  def nrecords()
    self.voter_transaction_logs.inject(0) do |n,vtl|
      n+vtl.voter_transaction_records.length
    end
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
  
end
