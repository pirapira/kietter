class SessionController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]
    user = User.find_existing(auth)
    unless user
      user = User.create_with_omniauth(auth)
    end
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end

  def destroy
    session.clear
    redirect_to :back, :notice => "Signed out!"
  end
end
