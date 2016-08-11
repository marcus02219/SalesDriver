class MonthlySchedule
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :seller, class_name: "User"

  validates :blocked_day, uniqueness: { scope: :seller_id }

  scope :repeat_days, -> { where(repeat: true).order("DESC blocked_day")}

  field :blocked_day,                     :type => Date
  field :repeat,                          :type => Boolean, default: false
  # field :status,                          :type => String

  # extend Enumerize
  # enumerize :status, in: [:recurring, :specifics]
  def start_time
    self.blocked_day
  end

  def self.blocked_days(year, month)
    days = []
    repeat_days.each do |rd|
      ms = MonthlySchedule.new blocked_day: "#{year}-#{month}-#{rd.blocked_day.day}"
      days << ms
    end
    month = month - 1
    MonthlySchedule.where("this.blocked_day.getMonth() == #{month} && this.repeat==false").each do |ms|
      days << ms
    end
    days
  end

end
