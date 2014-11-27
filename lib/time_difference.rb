require 'rubygems'
require "active_support/all"

class TimeDifference

  def self.between(start_date, end_date)
  	@start_date, @end_date = start_date, end_date
  	self
  end

  class << self

  	[:years, :months, :weeks, :days, :hours, :minutes, :seconds].each do |time_component|
  		self.class.instance_eval do
  			define_method("in_#{time_component}") do
  				if time_component == :months
  					((@time_diff/(1.days * 30.42)).round(2)).abs
  				else
  			 		((@time_diff/1.send(time_component)).round(2)).abs
  			 	end
  			end
  		end
  	end

  end

  def self.in_each_component
    time_in_each_component = {}
    [:years, :months, :weeks, :days, :hours, :minutes, :seconds].each do |time_component|
      if time_component == :months
        time_in_each_component[time_component] = ((@time_diff/(1.days * 30.42)).round(2)).abs
      else
        time_in_each_component[time_component] = ((@time_diff/1.send(time_component)).round(2)).abs
      end
    end
    time_in_each_component
  end

  def self.in_general
    years = @end_date.year - @start_date.year
    months = @end_date.month - @start_date.month
    # Get # of days in previous month of end_date
    previous_days_in_month = Time.days_in_month(@end_date.month - 1, @end_date.year)
    # Then subtract difference between the day values
    day_difference = @end_date.day - @start_date.day
    # Lose one month and add day_difference offset
    if day_difference < 0
      months -= 1
      # If months is less than 0, add 12 and subtract one from year
      if months < 0
        months += 12
        year -=1
      end
      days = previous_days_in_month + day_difference
    # Number of months stays the same but day difference is the number of days
    else
      days = day_difference
    end
    # If days is negative, subtract 1 from months
    weeks = (days / 7).to_i
    days %= 7
  	{years: years, months: months, weeks: weeks, days: days}
  end

end
