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

  def fwab_form_note?
    self.form =~ /FWAB/
  end

  def fpca_form_note?
    self.form =~ /FPCA/
  end

  def reject_incomplete_notes?
    self.note =~ /rejectIncomplete/
  end

end
