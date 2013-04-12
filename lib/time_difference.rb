require "active_support/all"

class TimeDifference

  def self.between(start_time, end_time)
  	@time_diff = end_time - start_time
  	self
  end

  

end
