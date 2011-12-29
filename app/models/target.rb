class Target < ActiveRecord::Base
  validates_uniqueness_of :uid
  has_many :samples
  def Target.find_or_create(uid)
    ret = find(:first, :conditions => ["uid = ?", uid])
    return ret if ret
    ret = Target.new
    ret.uid = uid
    return ret if ret.save
    Target.find_or_create(uid)
  end
  def fill(u)
    return if sample_end && sample_end >= Time.now - 7.days
    arr = u.look self.uid
    Sample.fill(self,arr)
    self.sample_end = Time.now
    self.save!
  end
end
