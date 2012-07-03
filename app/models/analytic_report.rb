class AnalyticReport < ActiveRecord::Base
  validates_presence_of :num
  belongs_to :election

  def fill
    self.day = DateTime.now
    self.data = ""
    case self.num
    when 1
      self.name="Voter Participation Report"
      self.desc="What Report #1 does is ..."
    when 2
      self.name="Voter Outcome Report"
      self.desc="What Report #2 does is ..."
    when 3
      self.name="UOCAVA Voter Online Usage Report"
      self.desc="What Report #3 does is ..."
    when 4
      self.name="UOCAVA Voter Activity Report"
      self.desc="What Report #4 does is ..."
    else
      raise Exception, "Unknown Report Number: "+self.num.to_s
    end
    self.data = ""
    self.save
  end

  def get_data
    return ActiveSupport::JSON.decode(self.data)
  end

  def set_data(datum)
    self.data = ActiveSupport::JSON.encode(datum).to_s
    self.save
  end

  def unset_data(datum)
    self.data = ""
    self.save
  end

  def stale_data(update=false)
    return (self.data == "" || (update && update > self.updated_at))
  end

end
