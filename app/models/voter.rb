class Voter < ActiveRecord::Base
  validates_presence_of :vname
  belongs_to :election
  has_many :voter_transaction_records, :order => 'datime ASC'
end
