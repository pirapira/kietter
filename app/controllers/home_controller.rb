class HomeController < ApplicationController
  def index
    return if session[:user_id]
    # not logged in
    redirect_to "/auth/twitter"
    return
  end
end
