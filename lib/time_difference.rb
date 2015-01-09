require 'rubygems'
require "active_support/all"

class TimeDifference

  def self.between(start_time, end_time)
    start_time = time_in_seconds(start_time)
    end_time = time_in_seconds(end_time)

    @time_diff = end_time - start_time

    self
  end

  def self.time_in_seconds(time)
    time.to_time.to_f
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
    result = {}
    [:years, :months, :weeks, :days, :hours, :minutes, :seconds].each do |time_component|
      result[time_component] = (@time_diff/1.send(time_component)).floor
      @time_diff = (@time_diff - result[time_component].send(time_component))
    end
    result
  end

end
