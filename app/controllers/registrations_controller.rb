class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication
  before_filter :resource_name

  def resource_name
    :user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
    @user.phone_code = User.digital_code
    if @user.save
      redirect_to "/", :notice => "Sent confirmation email"
    else
      render 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :company, :address1, :address2, :state, :city, :country, :phone_number, :postalcode)
  end
end
