class MonthlySchedule
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :seller, class_name: "User"

  field :day,                     :type => Date
  field :status,                  :type => String

  extend Enumerize
  enumerize :status, in: [:recurring, :specifics]
end
