class Sample < ActiveRecord::Base
  require 'set'
  belongs_to :target
  validates_uniqueness_of :period, :scope => [:target_id]
  def Sample.fill(target, arr)
    return if arr == []
    arr.each {|t| t.utc}
    arr = arr.collect {|t| t.soroe}
    arr.sort!
    s = Set.new arr
    kara = arr[0]
    made = arr[-1]
    tmp  = kara
    while tmp <= made && tmp <= Time.now
      samp = Sample.find(:first, :conditions => ["target_id = ? AND period = ?",
               target.id, tmp])
      samp = Sample.new unless samp
      samp.target_id = target.id
      samp.period = tmp
      samp.presence = s.include? tmp
      samp.save
      tmp += DateTime.tanni
    end
  end
end
