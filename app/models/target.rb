class Target < ActiveRecord::Base
  validates_uniqueness_of :uid
  def Target.find_or_create(uid)
    ret = find(:first, :conditions => ["uid = ?", uid])
    return ret if ret
    ret = Target.new
    ret.uid = uid
    return ret if ret.save
    Target.find_or_create(uid)
  end
  def fill(u)
    require 'yaml'
    return if sample_end && sample_end >= Time.now - 7.days
    arr = u.look(self.uid, sample_end)
    arr.each {|t| t.utc}
    arr = arr.collect {|t| t.soroe}
    arr = YAML::load(self.samples) + arr if self.samples
    arr.sort!.uniq!
    self.samples = YAML::dump(arr)
    self.sample_end = Time.now
    self.save!
  end
end
