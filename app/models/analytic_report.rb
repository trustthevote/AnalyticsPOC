class AnalyticReport < ActiveRecord::Base
  validates_presence_of :num
  belongs_to :election

  def fill
    self.day = DateTime.now
    self.data = ""
    case self.num
    when 1
      self.name="Voter Participation Report"
    when 2
      self.name="Voter Outcome Report"
    when 3
      self.name="UOCAVA Voter Online Usage Report"
    when 4
      self.name="UOCAVA Voter Activity Report"
    else
      raise Exception, "Unknown Report Number: "+self.num.to_s
    end
    self.save
  end

  def get_data
    return ActiveSupport::JSON.decode(self.data)
  end

  def set_data(datum)
    self.data = ActiveSupport::JSON.encode(datum).to_s
    self.save
  end

  def stale_data(update=false)
    return (self.data == "" || (update && update > self.updated_at))
  end

  def linebreak(n)
    len = self.data.length
    return self.data if len <= n
    return self.lbreak(self.data,n)
  end

  def lbreak(str,n)
    len = str.length
    return str if len <= n
    lbchar = " "
    while (n < len)
      if str[n] =~ /[:,}]/
        return str[0..n]+lbchar+lbreak(str[n+1..-1],n)
      elsif str[n] =~ /{/
        return str[0..n-1]+lbchar+lbreak(str[n..-1],n)
      else
        n += 1
      end
    end
    return str
  end

end
