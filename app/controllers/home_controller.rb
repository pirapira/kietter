class HomeController < ApplicationController
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
    end
    # now logged in
    c = current_user.client
    a_user = c.user a
    b_user = c.user b
  end
end
