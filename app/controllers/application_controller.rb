class ApplicationController < ActionController::API

  def authenticate_user_token
    puts "Authorization#{request.headers['Authorization']}"

    user = User.find_by(auth_token: request.headers['Authorization'])
    return render(json: { message:'invalid token' }, status: 401) if user.nil?

    sign_in(user, store: false)
  end
end
