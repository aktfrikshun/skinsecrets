class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    unless @current_user
      redirect_to login_path, alert: "Please log in to continue."
    end
  end

  def logged_in?
    !!@current_user
  end

  def current_user
    @current_user
  end

  def require_admin
    unless @current_user&.email == "admin@skinsecretsnc.com"
      redirect_to root_path, alert: "Admin access required."
    end
  end

  helper_method :logged_in?, :current_user
end
