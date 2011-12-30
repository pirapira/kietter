# coding: utf-8

class HomeController < ApplicationController
  require 'yaml'
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
    logger.info "----------------------now logged in "
    begin
      c = current_user.client
      raise Twitter::Error::BadRequest if c.rate_limit_status.remaining_hits < 20
      a_user = c.user a
      b_user = c.user b
      a_uid  = a_user.attrs["id"]
      b_uid  = b_user.attrs["id"]
      @a = a_user.attrs["screen_name"]
      @b = b_user.attrs["screen_name"]
      a_target = Target.find_or_create a_uid
      b_target = Target.find_or_create b_uid
    logger.info "----------------------target set"
      a_th = Thread.new {a_target.fill(current_user)}
      b_target.fill(current_user)
      a_th.join
    logger.info "----------------------filled"
      a_samples = YAML::load(a_target.samples)
      b_samples = YAML::load(b_target.samples)
    logger.info "----------------------loaded "
      k = kentei(a_samples, b_samples)
      @pval = k[:pval]
      @cov  = k[:cov]
    rescue Twitter::Error::Unauthorized
      session[:notice] = "鍵つきアカウントには使えません．"
      redirect_to root_url
    rescue Twitter::Error::NotFound
      session[:notice] = "そのひとはみつかりません．"
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
    kara = [a_arr[0], b_arr[0]].max
    made = [a_arr[-1],b_arr[-1]].min
    raise Exception if kara > made
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
    return 0.0 if as == bs && as.length > 5
    R.eval "y.data <- data.frame( as = a_row, bs = b_row, cs = c_row )"
    R.eval "library(ppcor)"
    begin
      results = R.pull 'as.numeric(pcor.test(y.data$as,y.data$bs,y.data[,c("cs")]))'
    rescue NoMethodError
      results = [nil,nil]
    end
    return {:pval => results[1], :cov => results[0]}
  end 
end
