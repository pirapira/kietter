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
      return
    end
    # now logged in
    c = current_user.client
    a_user = c.user a
    b_user = c.user b
    a_uid  = a_user.attrs["id"]
    b_uid  = b_user.attrs["id"]
    a_target = Target.find_or_create a_uid
    b_target = Target.find_or_create b_uid
    a_target.fill(current_user)
    b_target.fill(current_user)
    @a_samples = a_target.samples
    @b_samples = b_target.samples
  end
end
