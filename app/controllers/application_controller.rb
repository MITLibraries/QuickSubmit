class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :store_current_location, unless: :devise_controller?

  def store_current_location
    store_location_for(:user, request.url)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def new_session_path(_scope)
    root_path
  end
end
