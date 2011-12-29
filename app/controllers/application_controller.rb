class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from ActionView::MissingTemplate, :with => :render_html

  helper_method :current_user

  def render_html
    if Rails.env.production?
      render :format => "html"
    else
      raise ActionView::MissingTemplate
    end
  end

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue
      session[:user_id] = nil
      current_user
    end
  end
end
