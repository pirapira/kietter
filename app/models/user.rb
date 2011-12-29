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
  def look(target) # target can be uid or screen_name
    c = client
    first = true
    ret = []
    last_id_str = nil
    begin
      tl = nil
      retry_num = 3
      begin
        if first
          tl = c.user_timeline(target, :include_rts => true, :count => 200)
        else
          tl = c.user_timeline(target, :include_rts => true, :count => 200, :max_id => last_id_str)
        end
      rescue Twitter::Error::BadGateway
        retry_num = retry_num - 1
      end while ((tl == nil) && (retry_num > 0))
      break if tl == []
      if first
        ret += tl.collect {|t| t.attrs["created_at"].to_datetime}
      else
        ret += tl.drop(1).collect {|t| t.attrs["created_at"].to_datetime}
      end
      new_id_str = tl[-1].attrs["id_str"]
      break if new_id_str == last_id_str
      last_id_str = new_id_str
      first = false
    # debug

      puts tl[-1].attrs["created_at"]
    end while true
    return ret
  end
end
