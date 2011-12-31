# coding: utf-8

class HomeController < ApplicationController
  require 'yaml'
  class Tsukaisugi < Exception
  end
  class NotEnoughData < Exception
  end
  def index
  end
  def investigate
    if session[:a] || session[:b]
      a = session[:a]
      b = session[:b]
      session[:a] = session[:b] = nil
    else 
      a = params[:a]
      b = params[:b]
    end
    unless current_user
      session[:a] = a
      session[:b] = b
      redirect_to "/auth/twitter"
      return
    end
    # now logged in
    begin
      c = current_user.client
      c.current_user
      raise Tsukaisugi if c.rate_limit_status.remaining_hits < 20
      if a == "" || b == ""
        session[:notice] = "empty screen names given."
        redirect_to root_url
        return
      end
      a_user = c.user a
      b_user = c.user b
      a_uid  = a_user.attrs["id"]
      b_uid  = b_user.attrs["id"]
      @a = a_user.attrs["screen_name"]
      @b = b_user.attrs["screen_name"]
      if a_uid == b_uid
        @same = true
        return
      end
      a_target = Target.find_or_create a_uid
      b_target = Target.find_or_create b_uid
      a_th = Thread.new {a_target.fill(current_user)}
      b_target.fill(current_user)
      a_th.join
      a_samples = YAML::load(a_target.samples)
      b_samples = YAML::load(b_target.samples)
      k = kentei(a_samples, b_samples)
      @pval = k[:pval]
      @cov  = k[:cov]
    rescue MultiJson::DecodeError
      session[:notice] = "twitter returned something strange"
      redirect_to root_url
    rescue NotEnoughData
      session[:notice] = "なんかtweetが拾えませんでした．"
      redirect_to root_url
    rescue Twitter::Error::Unauthorized
      current_user.destroy
      session[:user_id] = nil
      session[:notice] = "認証がうまくいっていないようです．あるいは，フォローしていない鍵つきアカウントをみようとしたのかも．"
      redirect_to root_url
    rescue Twitter::Error::NotFound
      session[:notice] = "そのひとはみつかりません．"
      redirect_to root_url
    rescue Tsukaisugi
      session[:notice] = "つかいすぎです．"
      redirect_to root_url
    rescue Twitter::Error::ServiceUnavailable
      session[:notice] = "Twitterからservice unavailableっていわれたけど，もいちどためすとうまくいくかも"
      redirect_to root_url
    rescue Twitter::Error::BadRequest
      session[:notice] = "つかいすぎです．"
      redirect_to root_url
    end
  end

  private

  def kentei(a_arr, b_arr)
    require "rinruby"
    require 'set'
    raise NotEnoughData unless a_arr[0] && b_arr[0]
    kara = [a_arr[0], b_arr[0],(Time.now - 3.months).to_datetime.soroe].max.soroe
    made = [a_arr[-1],b_arr[-1],(Time.now).to_datetime.soroe].min.soroe
    a_arr = a_arr.collect {|a| a.soroe}
    b_arr = b_arr.collect {|b| b.soroe}
    raise NotEnoughData if kara > made
    a_set = Set.new a_arr
    b_set = Set.new b_arr
    range = []
    tmp = kara
    while tmp <= made
      range = range + [tmp]
      tmp += DateTime.tanni
    end
    # now use R
    R.assign "a_row", (as = range.collect {|t| if a_set.include? t then 1 else 0 end})
    R.assign "b_row", (bs = range.collect {|t| if b_set.include? t then 1 else 0 end})
    R.assign "c_row", (range.collect {|t| t.hour})
    R.assign "d_row", (range.collect {|t| t.wday})
    return {:pval => 0.0, :cov => 1.0} if as == bs && as.length > 5
    R.eval "y.data <- data.frame( as = a_row, bs = b_row, cs = c_row, ds = d_row )"
    R.eval "library(ppcor)"
    begin
      results = R.pull 'as.numeric(pcor.test(y.data$as,y.data$bs,y.data[,c("cs", "ds")]))'
    rescue NoMethodError
      results = [nil,nil]
    end
    return {:pval => results[1], :cov => results[0]}
  end 
end
