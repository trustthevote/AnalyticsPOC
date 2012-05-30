class ElectionArchive < ActiveRecord::Base
  validates_presence_of :eid
end
