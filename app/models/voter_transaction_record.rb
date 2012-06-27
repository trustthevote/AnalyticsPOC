class VoterTransactionRecord < ActiveRecord::Base
  validates_presence_of :vname
  validates_presence_of :datime
  validates_presence_of :action
  belongs_to :voter_transaction_log

  def archived
    if vtl = VoterTransactionLog.find(self.voter_transaction_log_id)
      return vtl.archived
    else
      return true
    end
  end

  def date
    return self.datime.strftime("%B %-d, %Y")
  end

end
