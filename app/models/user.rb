class User < ActiveRecord::Base
  validates_uniqueness_of :uid, :scope => :provider
  def self.create_with_omniauth(auth)
    create! do |user|
      user.set_by(auth)
      Name.add_name(user.screen_name)
    end
  end
  def self.find_existing(auth)
    ret = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    if ret
      ret.set_by(auth)
      ret.save! # changing screen name and so on
    end
    return ret
  end
  def set_by(auth)
    self.provider = auth["provider"]
    self.uid = auth["uid"].to_i
    self.name = auth["user_info"]["name"]
    self.screen_name = auth["user_info"]["nickname"]
    self.token = auth['credentials']['token']
    self.secret = auth['credentials']['secret']
  end
end
