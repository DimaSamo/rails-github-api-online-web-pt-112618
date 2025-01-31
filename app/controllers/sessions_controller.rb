class SessionsController < ApplicationController
  skip_before_action :authenticate_user

  def create
    resp = Faraday.post 'https://github.com/login/oauth/access_token' do |req|
      req.params['client_id'] = ENV['GITHUB_CLIENT']
      req.params['client_secret'] = ENV['GITHUB_SECRET']
      req.params['code'] = params[:code]
      req.params['redirect_uri'] = "http://localhost:3000/auth"
      req.headers["Accept"] = "application/json"
    end
    @body = JSON.parse(resp.body)["access_token"]
    session[:token] = @body

    user_response = Faraday.get "https://api.github.com/user", {}, {'Authorization' => "token #{session[:token]}", 'Accept' => 'application/json'}
    user_json = JSON.parse(user_response.body)
    session[:username] = user_json["login"]

    redirect_to root_path
  end
end
