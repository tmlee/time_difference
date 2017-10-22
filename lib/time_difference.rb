require 'rubygems'
require "active_support/all"

class TimeDifference

  private_class_method :new

  TIME_COMPONENTS = [:years, :months, :weeks, :days, :hours, :minutes, :seconds]

  def self.between(start_time, end_time)
    new(start_time, end_time)
  end

  # Defining methods dynamically as in_years, in_months, etc.

  TIME_COMPONENTS.each do |time_component|
    define_method("in_#{time_component.to_s}") do
      return @time_diff.round if time_component == :seconds
      return (@time_diff / (1.day * 30.42)).round if time_component == :months
      in_component(time_component)
    end
  end

  def in_each_component
    Hash[TIME_COMPONENTS.map do |time_component|
      [time_component, public_send("in_#{time_component}")]
    end]
  end

  def in_general
    remaining = @time_diff
    Hash[TIME_COMPONENTS.map do |time_component|
      if remaining > 0
        rounded_time_component = (remaining / 1.send(time_component).seconds).round(2).floor
        remaining -= rounded_time_component.send(time_component)
        [time_component, rounded_time_component]
      else
        [time_component, 0]
      end
    end]
  end

  def humanize
    diff_parts = []
    in_general.each do |part,quantity|
      next if quantity <= 0
      part = part.to_s.humanize

      if quantity <= 1
        part = part.singularize
      end

      diff_parts << "#{quantity} #{part}"
    end

    last_part = diff_parts.pop
    if diff_parts.empty?
      return last_part
    else
      return [diff_parts.join(', '), last_part].join(' and ')
    end
  end

  private

  def initialize(start_time, end_time)
    start_time = time_in_seconds(start_time)
    end_time = time_in_seconds(end_time)

    @time_diff = (end_time - start_time).abs
  end

  def time_in_seconds(time)
    time.to_time.to_f
  end

  def in_component(component)
    (@time_diff / 1.send(component)).round
  end

end