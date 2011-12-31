class DateTime
  def DateTime.tanni
    1.hour
  end
  def soroe
    y = self.utc.year
    mon = self.utc.month
    day = self.utc.day
    hour = self.utc.hour
    DateTime.new( y, mon, day, hour)
  end
  def classify
    hour
  end
end
