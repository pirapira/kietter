class Sample < ActiveRecord::Base
  require 'set'
  belongs_to :target
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
      samp = Sample.new
      samp.target_id = target.id
      samp.period = tmp
      samp.presence = s.include? tmp
      samp.save
      tmp += Time.tanni
    end
  end
end
