class VoterTransactionRecord < ActiveRecord::Base
  validates_presence_of :vname
  validates_presence_of :datime
  validates_presence_of :action
  belongs_to :voter_transaction_log
end
