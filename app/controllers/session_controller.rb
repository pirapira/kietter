class SessionController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]
    user = User.find_existing(auth)
    unless user
      user = User.create_with_omniauth(auth)
    end
    session[:user_id] = user.id
    redirect_to url_for :controller => :home, :action => :investigate
  end
  def error
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def destroy
    session.clear
    redirect_to root_url
  end
end
