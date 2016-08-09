class WeeklySchedule
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :seller, class_name: "User"
  has_many :time_schedules, dependent: :destroy
  accepts_nested_attributes_for :time_schedules, reject_if: :all_blank, allow_destroy: true

  field :order_number,            :type => Integer
  field :week,                    :type => String
  field :work_day,                :type => Boolean, default: true

  extend Enumerize
  enumerize :week, in: [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
end
