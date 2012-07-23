class VoterRecord < ActiveRecord::Base

  def uocava?
    self.military? or self.overseas?
  end
  
  def military?
    self.military =~ /y/i
  end
  
  def overseas?
    self.overseas =~ /y/i
  end
  
  def absentee_status?
    self.status=~/abs/i || self.uocava?
  end
  
  def absentee_ulapsed?
    self.uocava? && !(self.status=~/abs/i)
  end
  
  def male?
    self.gender =~ /m/i
  end

  def female?
    self.gender =~ /f/i
  end

  def party_democratic?
    self.party=~/democratic/i
  end

  def party_republican?
    self.party=~/republican/i
  end

  def party_other?
    !self.party_democratic? && !self.party_republican?
  end

  def new?(e)
    (self.regidate >= e.voter_start_day and
     self.regidate <= e.voter_end_day)
  end
  
end
