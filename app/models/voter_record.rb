class VoterRecord < ActiveRecord::Base

  def uocava
    self.vtype=~/uoc/i
  end
  
  def absentee_status
    self.status=~/abs/i || self.vtype=~/uoc/i
  end
  
  def absentee_ulapsed
    self.vtype=~/uoc/i && !(self.status=~/abs/i)
  end
  
  def new
    (self.vname[1..-1].to_i)%5==0
  end

  def male
    self.gender=~/m/i
  end

  def female
    self.gender=~/f/i
  end

  def party_democratic
    self.party=~/democratic/i
  end

  def party_republican
    self.party=~/republican/i
  end

  def party_other
    !self.party_democratic && !self.party_republican
  end

end
