class ApplicationDelivery < ActiveDelivery::Base
  register_line :notifier, ActiveDelivery::Lines::Notifier
end
