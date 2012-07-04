class Voter < ActiveRecord::Base
  validates_presence_of :vname
  belongs_to :election
  has_many :voter_transaction_records, :order => 'datime ASC'

  def archived
    if e = Election.find(self.election_id)
      return e.archived
    else
      return true
    end
  end

  def vtrs
    self.voter_transaction_records
  end

  def uocava
    self.vtype=~/uoc/i
  end
  
  def new
    self.vnew
  end

  def vru
    self.vupdate=~/approve/i
  end

  def male
    self.vgender=~/m/i
  end

  def female
    self.vgender=~/f/i
  end

  def party_democratic
    self.vparty=~/democratic/i
  end

  def party_republican
    self.vparty=~/republican/i
  end

  def party_other
    !self.party_democratic && !self.party_republican
  end

  def asr_approved
    self.vabsreq=~/approve/i
  end

  def asr_rejected
    self.vabsreq=~/reject/i
  end

  def vru_approved
    self.vupdate=~/approve/i
  end

  def vru_rejected
    self.vupdate=~/reject/i
  end

  def military
    self.vother=~/military/i
  end
  
  def absentee_status
    self.vstatus=~/abs/i || self.vtype=~/uoc/i
  end
  
  def absentee_ulapsed
    self.vtype=~/uoc/i && !(self.vstatus=~/abs/i)
  end
  
  def voted_provisional
    self.vform=~/pro/i
  end

  def voted_absentee
    self.vform=~/abs/i
  end

  def voted_inperson
    self.vform=~/reg/i
  end

  def ballot_accepted
    !self.vreject
  end

  def ballot_rejected
    self.vreject
  end

  def ballot_rejected_late
    self.vreject && (self.vnote=~/late/i)
  end

  def ballot_rejected_notlate
    self.vreject && !(self.vnote=~/late/i)
  end

end
