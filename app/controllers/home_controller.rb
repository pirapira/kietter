class HomeController < ApplicationController
  def index
  end
  def investigate
    if session[:a] || session[:b]
      @a = session[:a]
      @b = session[:b]
      session[:a] = session[:b] = nil
    else 
      @a = params[:a]
      @b = params[:b]
    end
    return if session[:user_id]

    # not logged in
    session[:a] = @a
    session[:b] = @b
    redirect_to "/auth/twitter"
    return
  end
end
