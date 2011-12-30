class User < ActiveRecord::Base
  validates_uniqueness_of :uid, :scope => :provider
  def self.create_with_omniauth(auth)
    create! do |user|
      user.set_by(auth)
    end
  end
  def self.find_existing(auth)
    ret = User.find_by_provider_and_uid(auth["provider"], auth["uid"].to_i)
    if ret
      ret.set_by(auth)
      ret.save! # changing screen name and so on
    end
    return ret
  end
  def set_by(auth)
    self.provider = auth["provider"]
    self.uid = auth["uid"].to_i
    self.name = auth["info"]["name"]
    self.screen_name = auth["info"]["nickname"]
    self.token = auth['credentials']['token']
    self.secret = auth['credentials']['secret']
  end
  def client
    Twitter::Client.new(:oauth_token => self.token,
               :oauth_token_secret => self.secret)
  end
  def look(target,since) # target can be uid or screen_name
    if since
      since = [since, Time.now - 1.month].max
    else
      since = Time.now - 1.month
    end
    c = client
    ret = []
    last_id_str = nil
    n = 0
    begin
      break if n >= 4
      th1 = Thread.new{ getpage(1 + 4 * n, c, target)}
      th2 = Thread.new{ getpage(2 + 4 * n, c, target)}
      th3 = Thread.new{ getpage(3 + 4 * n, c, target)}
      th4 = Thread.new{ getpage(4 + 4 * n, c, target)}
      tl = th1.value + th2.value + th3.value + th4.value
      break if tl == []
      ret += tl.collect {|t| t.attrs["created_at"].to_datetime}
      n = n + 1
    end while tl[-1].attrs["created_at"].to_datetime >= since
    reached = ret.length > 0 && ret[-1] < since
    return {:array => ret, :reached => reached}
  end
  def getpage(pnum,c,target)
    tl = nil
    retry_num = 3
    begin
      tl = c.user_timeline(target, :include_rts => true, :count => 200, :page => pnum)
    rescue Twitter::Error::BadGateway
      retry_num = retry_num - 1
    rescue
      return []
    end while ((tl == nil) && (retry_num > 0))
    return [] unless tl
    return tl
  end
end
