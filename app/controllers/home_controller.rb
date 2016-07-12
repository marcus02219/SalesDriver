class HomeController < ApplicationController
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  def index
  end

  # Create account API
  # POST: /api/v1/accounts/create
  # Parameters:
  #  email:          String *required
  #  password:       String *required minimum 6
  #  phone_number:   String *required

  # results:
  #   return created message

  def create
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'

    email         = params[:email].downcase
    password      = params[:password]
    phone_number  = params[:phone_number]

    if User.where(email:email).first.present?
      render json:{status: 0, data: 'This email already exists. Please try another email'} and return
    end
    if User.where(phone_number:phone_number).first.present?
      render json:{status: 0, data: 'This phone number already exists.'} and return
    end
    user = User.new(email:email, password:password, phone_number:phone_number, phone_code:User.digital_code, verified: false)
    if user.save
      user.reminder
      if sign_in(:user, user)
        render :json => {status: 1, :data => "Sent verification code to your phone"}
      else
        render json: {status: 0, :data => 'Can not create your account'}
      end
    else
      render :json => {status: 0, :data => user.errors.messages}
    end
  end
  # Destroy account API
  # POST: /api/v1/accounts/destroy
  # parameters:
  #   token:      String *required
  # results:
  #   return success string
  def destroy
    user   = User.find_by_token params[:token]
    if user.present?
      if user.destroy
        sign_out(resource)
        render :json => {status: 1, data: 'deleted account'}
      else
        render :json => {status: 0, data: "cannot delete this user"}
      end
    else
      render :json => {status: 0, data: "cannot find user"}
    end
  end

  # Login API
  # POST: /api/v1/accounts/sign_in
  # parameters:
  #   email:        String *required
  #   password:     String *required
  #   device_token: String *required
  # results:
  #   return user_info
  def create_session
    if params[:social_type].present?
      social_sign_in(params) and return
    end
    email         = params[:email]
    password      = params[:password]
    device_token  = params[:device_token]
    resource = User.find_for_database_authentication( :email => email )
    if resource.nil?
      render :json => {status: 0, data: 'No Such User'}
    else
      if resource.valid_password?( password )
        if resource.verified == false
          resource.update(phone_code: User::digital_code)
          render :json => {status: -1,  data: {phone_number: resource.phone_number, message: "Please verify your phone number and try again."}}
        else
          resource.update(device_token: device_token)
          user = sign_in( :user, resource )
          render :json => {status: 1, :data => resource.info_by_json}
        end
      else
        render :json => {status: 0,  data: "Password is wrong"}
      end
    end
   end

   # LogOut API
   # POST: /api/v1/accounts/sign_out
   # parameters:
   #   email:      String *required
   # results:
   #   return user_info
   def delete_session
    if params[:email].present?
        resource = User.find_for_database_authentication(:email => params[:email])
    elsif params[:user_id].present?
      resource = User.find(params[:user_id])
    end

    if resource.nil?
       render :json => {status: 0, data:'No Such User'}
    else
    sign_out(resource)
       render :json => {status: 1, :data => 'sign out'}
    end
  end

  # Login API using social
  # POST: /api/v1/accounts/social_sign_in
  # parameters:
  #   email:        String *required
  #   token:        String *required
  #   social_type:  String *required
  #   device_token: String *required
  #   first_name:   String
  #   last_name:    String
  #   photo_url:    String

  # results:
  #   return user_info

  def social_sign_in
    if params[:token].present?
      email        = params[:email].downcase    if params[:email].present?
      token        = params[:token]
      social_type  = params[:social_type]
      password     = params[:token][0..10]
      photo_url    = params[:photo_url]
      first_name   = params[:first_name]
      last_name    = params[:last_name]
      device_token = params[:device_token]
      user = User.any_of({:email=>email}).first
      if user.present?
        user.update(first_name: first_name, last_name: last_name, token: token, verified: true, device_token:device_token, remote_photo_url: photo_url)
        if sign_in(:user, user)
          render json: {status: 1, data: user.info_by_json}
        else
          render json: {status: 0, data: 'cannot login'}
        end
      else
          user = User.new(
              email:email,
              token:token,
              password:password,
              device_token: device_token,
              first_name:first_name,
              last_name:last_name,
              social_type:social_type,
              remote_photo_url: photo_url,
              verified: true
              )
        if user.save
          if sign_in(:user, user)
            render json: {status: 1, :data => user.info_by_json}
          else
            render json: {status: 0, :data => 'cannot login'}
          end
        else
          render :json => {status: 0, :data => user.errors.messages}
        end
      end
    end
  end


end
