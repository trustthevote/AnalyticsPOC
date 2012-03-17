class Election < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :day
  has_many :voter_transaction_logs, :dependent => :destroy
end
