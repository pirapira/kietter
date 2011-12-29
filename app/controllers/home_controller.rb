class HomeController < ApplicationController
  def index
  end
  def investigate
    return if session[:user_id]
    # not logged in
    redirect_to "/auth/twitter"
    return
  end
end
