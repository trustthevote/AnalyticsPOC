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

end
