class Selection < ActiveRecord::Base
  validates_presence_of :eid
  validates_presence_of :ename
end
