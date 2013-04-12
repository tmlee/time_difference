require "active_support/all"

class TimeDifference

  def self.between(start_time, end_time)
  	@time_diff = end_time - start_time
  	self
  end

  class << self

  	[:years, :months, :weeks, :days, :hours, :minutes, :seconds].each do |time_component|
  		self.class.instance_eval do
  			define_method("in_#{time_component}") do
  				if time_component == :months
  					(@time_diff/(1.days * 30.42)).round(2)		
  				else
  			 		(@time_diff/1.send(time_component)).round(2)
  			 	end
  			end
  		end
  	end

  end

end
