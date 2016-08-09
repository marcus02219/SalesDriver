class TimeSchedule
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :seller, class_name: "User"
  belongs_to :weekly_schedule, dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :check_time

  field :order_number,            :type => Integer
  field :name,                    :type => String

  field :start_time,         	    :type => Time
  field :end_time,         		    :type => Time
  field :ended_time,              :type => Time

  field :breacked_time,           :type => Integer



  def check_time
    if self.start_time > self.end_time
      errors.add(:end_time, "please check end_time")
    elsif self.end_time - self.start_time < 1800
      errors.add(:end_time, "start_time and end_time intervals should be at least 30min")
    end
  end
end
