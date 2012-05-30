class Selection < ActiveRecord::Base
  validates_presence_of :eid

  def eok
    return false if self.eid == nil
    return Election.all.any? {|e| e.id == self.eid}
  end

  def haslogs
    return false if self.eid == nil
    Election.all.each do |e|
      if e.id == self.eid
        return (e.voter_transaction_logs.length > 0) 
      end
    end
    return false
  end

  def elec
    return false if self.eid == nil
    Election.all.each do |e|
      return e if e.id == self.eid
    end
    return false
  end

end
