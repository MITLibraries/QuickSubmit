module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :developer

    def mit_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = "Welcome #{@user.email}!"
    end

    def developer
      raise 'Invalid Authentication' unless ENV['FAKE_AUTH_ENABLED'] == 'true'
      @user = User.from_omniauth(request.env['omniauth.auth'])
      @user.admin = true
      @user.save
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = "Welcome #{@user.email}!"
    end
  end
end
