class AnalyticReport < ActiveRecord::Base
  validates_presence_of :num
  belongs_to :election

  def fill
    self.day = DateTime.now
    self.data = ""
    case self.num
    when 1
      self.name="Report #1"
      self.desc="What Report #1 does is ..."
    when 2
      self.name="Report #2"
      self.desc="What Report #2 does is ..."
    when 3
      self.name="Report #3"
      self.desc="What Report #3 does is ..."
    when 4
      self.name="Report #4"
      self.desc="What Report #4 does is ..."
    else
      raise Exception, "Unknown Report Number: "+self.num.to_s
    end
    self.data = "{\"nreports\":"+self.num.to_s+"}"
    self.save
  end

  def get_val(key)
    datum = self.get_data
    if (datum.is_a?(Hash) && datum.keys.include?(key))
      return datum[key].to_s
    end
    return ""
  end

  def get_data
    return ActiveSupport::JSON.decode(self.data)
  end

  def set_data(datum)
    self.data = ActiveSupport::JSON.encode(datum).to_s
    self.save
  end

end
