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
end
