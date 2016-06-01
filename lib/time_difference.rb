require 'rubygems'
require "active_support/all"

class TimeDifference

  private_class_method :new

  TIME_COMPONENTS = [:years, :months, :weeks, :days, :hours, :minutes, :seconds]

  def self.between(end_time, start_time, abs = true)
    new(end_time, start_time, abs)
  end

  def in_years
    in_component(:years)
  end

  def in_months
    (@time_diff / (1.day * 30.42)).round(2)
  end

  def in_weeks
    in_component(:weeks)
  end

  def in_days
    in_component(:days)
  end

  def in_hours
    in_component(:hours)
  end

  def in_minutes
    in_component(:minutes)
  end

  def in_seconds
    @time_diff
  end

  def in_each_component
    Hash[TIME_COMPONENTS.map do |time_component|
      [time_component, public_send("in_#{time_component}")]
    end]
  end

  def in_general
    remaining = @time_diff

    Hash[TIME_COMPONENTS.map do |time_component|
      rounded_time_component = (remaining / 1.send(time_component)).floor
      remaining -= rounded_time_component.send(time_component)

      [time_component, rounded_time_component]
    end]
  end

  private
  
  def initialize(end_time, start_time, abs)
    end_time = time_in_seconds(end_time)
    start_time = time_in_seconds(start_time)

    @time_diff = (end_time - start_time)
    @time_diff = @time_diff.abs if abs
  end

  def time_in_seconds(time)
    time.to_time.to_f
  end

  def in_component(component)
    (@time_diff / 1.send(component)).round(2)
  end

end
