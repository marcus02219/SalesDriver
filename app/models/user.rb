class User
  include Mongoid::Document
  attr_accessor :skip_password_validation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :phone_number, presence: true, uniqueness: true, :unless => :verified?
  validates :phone_code, presence: true, :unless => :verified?
  mount_uploader :photo, PhotoUploader

  ## Database authenticatable
  field :phone_number,        type: String, default: ""
  field :device_token,        type: String, default: ""
  field :phone_code,          type: String, default: ""
  field :verified,            type: Boolean, default: false

  field :company,             type: String, default: ""

  field :first_name,          type: String, default: ""
  field :last_name,           type: String, default: ""
  field :address1,            type: String, default: ""
  field :address2,            type: String, default: ""
  field :city,                type: String, default: ""
  field :state,               type: String, default: ""
  field :country,             type: String, default: ""
  field :postalcode,          type: String, default: ""

  field :photo,               type: String, default: ""

  field :user_type,           type: String, default: "client" # client, seller

  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at,     type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  field :social_type,         :type => String,    :default => "app"
  field :token,               :type => String,    :default => ""

  has_many :trials, dependent: :destroy
  has_many :clients, dependent: :destroy

  before_validation :check_user
  # after_create :reminder

  def reminder
    return if self.verified
    @twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    reminder = "Hi, Please use this number #{self.phone_code}"
    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => self.phone_number,
      :body => reminder,
    )
    puts message.to
  end

  def self.find_by_token(token)
    User.where(:token=>token).first
  end

  def self.digital_code
    (0...6).map{rand(9)}.join
  end

  def info_by_json
    user = self
    user_info={
      id:user.id.to_s,
      email:user.email,
      token:user.token,
      first_name: user.first_name,
      last_name: user.last_name,
      address1: user.address1,
      address2: user.address2,
      city: user.city,
      state: user.state,
      country: user.country,
      postalcode: user.postalcode,
      photo: user.photo_url
    }
  end

  # def generate_token(column)
  #   begin
  #     self[column] = SecureRandom.urlsafe_base64
  #   end while User.exists?(column => self[column])
  # end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless !User.where(token: random_token).blank?
    end
  end

  def photo_url
  	if self.photo.url.nil?
  		""
  	else
      if Rails.env.production?
        ENV['host_url'] + self.photo.url.gsub("#{Rails.root.to_s}/public/user/", "/public/user/")
      else
    		ENV['host_url'] + self.photo.url.gsub("#{Rails.root.to_s}/public/user/", "/user/")
      end
  	end
  end

  def password_match?
    self.password == self.password_confirmation
  end

  def check_user
    if user_type == 'seller'
      pswd = SecureRandom.urlsafe_base64(12)
      self.password              = pswd
      self.password_confirmation = pswd
      UserMailer.send_created_notification_to_seller(email, pswd).deliver_later
    else
      p ">>>>>>>>>> *error* >>>>>>>>>>"
    end
  end

  handle_asynchronously :reminder , :run_at => Proc.new { 3.seconds.from_now }

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  def confirmation_required?
    false if self.user_type == "seller"
  end


end
