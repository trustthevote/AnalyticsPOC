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

  def absentee_ballot_form?
    self.form =~ /AbsenteeBallot/
  end

  def absentee_request_form?
    self.form =~ /AbsenteeRequest/
  end

  def voter_registration_form?
    self.form =~ /VoterRegistration/
  end

  def record_update_form?
    self.form =~ /RecordUpdate/
  end

  def fwab_form?
    self.form =~ /FWAB/
  end

  def fpca_form?
    self.form =~ /FPCA/
  end

  def online_generated?
    self.form =~ /onlineGenerated/
  end

  def online_balloting?
    self.note =~ /onlineBalloting/
  end

  def reject_incomplete?
    self.note =~ /rejectIncomplete/
  end

  def reject_late?
    self.note =~ /rejectLate/
  end

  def pfeo?
    return 'online' if self.online_generated?
    return 'postal' if self.note=~/postal/
    return 'fax'    if self.note=~/fax/
    return 'email'  if self.note=~/email/
    return false    if self.note=~/personal/
    return 'postal'
  end

end
