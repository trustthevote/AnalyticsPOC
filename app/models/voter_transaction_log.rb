class VoterTransactionLog < ActiveRecord::Base
  validates_presence_of :origin
  validates_presence_of :datime
  validates_uniqueness_of :origin, :scope => [:datime, :origin_uniq],
                                   :message => "(+uniq) and daytime duplicated in pre-existing log file."
  belongs_to :election
  has_many :voter_transaction_records, :dependent => :destroy
end
