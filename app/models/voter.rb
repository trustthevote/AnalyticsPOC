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

  def military
    self.vother =~ /M/
  end
  
  def uocava
    self.vother =~ /[MO]/
  end
  
  def new
    (self.vname[1..-1].to_i)%5==0
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
    self.vparty != "" && !self.party_democratic && !self.party_republican
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

  def vrr_approved
    self.vregister=~/approve/i
  end

  def absentee_status
    self.vstatus=~/abs/i || self.uocava
  end
  
  def absentee_ulapsed
    self.uocava && !(self.vstatus=~/abs/i)
  end
  
  def voted_provisional
    self.vote_form=~/pro/i
  end

  def voted_absentee
    self.vote_form=~/abs/i
  end

  def voted_inperson
    self.vote_form=~/reg/i
  end

  def ballot_accepted
    !self.vote_reject
  end

  def ballot_rejected
    self.vote_reject
  end

  def ballot_rejected_late
    self.vote_reject && (self.vote_note=~/late/i)
  end

  def ballot_rejected_notlate
    self.vote_reject && !(self.vote_note=~/late/i)
  end

  def vtr_state_current
    [self.vonline, self.vregister, self.vupdate, self.vabsreq,
     self.votes, self.vote_reject, self.vote_note, self.vote_form]
  end

  def vtr_state_encode(values)
    values.each{|v|(v.is_a?(String) && v.gsub!("\+",""))}
    return ActiveSupport::JSON.encode(values).to_s
  end

  def vtr_state_decode(string)
    values = ActiveSupport::JSON.decode(string)
    return values.collect{|v|(v=~/true/i?true:(v=~/false/i?false:v))}
  end

  def vtr_state_push
    self.vtr_state = self.vtr_state_encode(self.vtr_state_current()) +
      "\+" + self.vtr_state
  end
    
  def vtr_state_pop # JVC Voter State
    state, states = self.vtr_state.split("\+",2)
    if states == ""
      raise Exception, "Fatal error, Voter vtr state popped too far"
    end
    self.vtr_state = states
    state, states = self.vtr_state.split("\+",2)
    self.vonline, self.vregister, self.vupdate, self.vabsreq,
      self.votes, self.vote_reject, self.vote_note,
      self.vote_form = self.vtr_state_decode(state)
  end
    
end
