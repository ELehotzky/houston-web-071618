class ApplicationController < ActionController::API
  before_action :check_authentication

  def encode_token(payload)
  # payload => { beef: 'steak' }
    JWT.encode(payload, 'app_wide_secret_for_every_user')
  # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
  end

  def auth_header
    # { 'Authorization': 'Bearer <token>' }
    request.headers['Authorization']
  end

  def current_user
    if decoded_token
      user_id = decoded_token["user_id"]
      User.find(user_id)
    end
  end

  def decoded_token
    # token => "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
    if auth_header
      token = auth_header.split(' ')[1]

      begin
        JWT.decode(token, 'app_wide_secret_for_every_user')[0]
        # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
        # [0] gives us the payload { "beef"=>"steak" }
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def check_authentication
    render json: { error: 'Please log in' }, status: 401 if !logged_in?
  end

  def logged_in?
    !!current_user
  end
end
