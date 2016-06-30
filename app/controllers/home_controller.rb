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
      render json:{status: :failure, data: 'This email already exists. Please try another email'} and return
    end
    user = User.new(email:email, password:password, phone_number:phone_number, phone_code:User.digital_code, verified: false)
    if user.save
      if sign_in(:user, user)
        render :json => {status: :success, :data => "Sent verification code to your phone"}
      else
        render json: {status: :failure, :data => 'Can not create your account'}
      end
    else
      render :json => {status: :failure, :data => user.errors.messages}
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
        render :json => {status: :success, data: 'deleted account'}
      else
        render :json => {status: :failure, data: "cannot delete this user"}
      end
    else
      render :json => {status: :failure, data: "cannot find user"}
    end
  end
  # Login API
  # POST: /api/v1/accounts/sign_in
  # parameters:
  #   email:      String *required
  #   password:   String *required
  # results:
  #   return user_info
  def create_session
    if params[:social]
      social_sign_in(params)
    end
    email    = params[:email]
    password = params[:password]
    resource = User.find_for_database_authentication( :email => email )
    if resource.nil?
      render :json => {status: :failure, data: 'No Such User'}
    else
      if resource.valid_password?( password )
        if resource.verified == false
          resource.update(phone_code: User::digital_code)
          resource.reminder
          render :json => {status: :failure,  data: "Please verify your phone number and try again."}
        else
          user = sign_in( :user, resource )
          render :json => {status: :success, :data => resource.info_by_json}
        end
      else
        render :json => {status: :failure,  data: "Password is wrong"}
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
       render :json => {status: :failure, data:'No Such User'}
    else
    sign_out(resource)
       render :json => {status: :success, :data => 'sign out'}
    end
  end


end
