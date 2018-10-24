require 'rubygems'
require 'active_support/all'

# [TimeDifference]
#
# TimeDifference is the missing Ruby method to calculate difference between two
#   given time. You can do a Ruby time difference in year, month, week, day,
#   hour, minute, and seconds.
#
# @since 2013-04-12
# @author TM Lee <tm89lee@gmail.com>, Joel Courtney <jcourtney@cozero.com.au>
class TimeDifference
  # @group Class Constants
  TIME_COMPONENTS = %i[years months weeks days hours minutes seconds].freeze
  DEFAULT_DATE_OPTIONS = {
    force_timezone: false,
    inclusive: false,
    timezone: 'UTC',
  }.freeze
  DEFAULT_IN_OPTIONS = {
    rounding: 2
  }.freeze
  # Ensure .initialize is a private method
  private_class_method :new

  # Initialize for a range
  #
  # Default options are:
  #   inclusive: false
  #   timezone: 'UTC'
  #
  # @param [Date, Time, DateTime] start_time
  # @param [Date, Time, DateTime] end_time
  # @param [Hash] options
  # @option options [String] :inclusive whether the calculations for dates
  #   consider a Date to be inclusive or exclusive.
  # @option options [String] :timezone what timezone to use for calculations.
  # @return [TimeDifference]
  def self.between(start_time, end_time, options = {})
    new(start_time, end_time, options)
  end

  # The difference in years
  #
  # @todo account for daylight savings
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_years(options = {})
    in_period(:years, options)
  end

  # The difference in calendar years
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_calendar_years(options = {})
    year_diff = (@finish.year - @start.year) - 1

    if year_diff < 0
      year_diff = (@finish - @start) / seconds_in_year_for_time(@start)
    else
      year_diff += ((@start.beginning_of_year + 1.year) - @start) / seconds_in_year_for_time(@start)
      year_diff += (@finish - @finish.beginning_of_year) / seconds_in_year_for_time(@finish)
    end

    year_diff.round(DEFAULT_IN_OPTIONS.merge(options)[:rounding])
  end

  # The difference in months
  #
  # @todo account for daylight savings
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_months(options = {})
    in_period(:months, options)
  end

  # The difference in calendar months
  #
  # @param [Integer] rounding
  # @return [Numeric]
  def in_calendar_months(options = {})
    month_diff = (12 * @finish.year + @finish.month) - (12 * @start.year + @start.month) - 1

    if month_diff < 0
      month_diff = (@finish - @start) / seconds_in_month_for_time(@start)
    else
      month_diff += ((@start.beginning_of_month + 1.month) - @start) / seconds_in_month_for_time(@start)
      month_diff += (@finish - @finish.beginning_of_month) / seconds_in_month_for_time(@finish)
    end

    month_diff.round(DEFAULT_IN_OPTIONS.merge(options)[:rounding])
  end

  # The difference in consistent (groups of 7).
  #
  # @todo account for daylight savings
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_weeks(options = {})
    in_period(:weeks, options)
  end

  # The difference in days
  #
  # @todo account for daylight savings
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_days(options = {})
    in_period(:days, options)
  end

  # The difference in hours
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_hours(options = {})
    in_component(:hours, options)
  end

  # The difference in minutes
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_minutes(options = {})
    in_component(:minutes, options)
  end

  # The difference in seconds
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_seconds(_rounding = nil)
    @time_diff
  end

  # The difference in each component available.
  #
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Hash]
  def in_each_component(options = {})
    Hash[TIME_COMPONENTS.map do |time_component|
      [
        time_component,
        public_send(
          "in_#{time_component}",
          options
        )
      ]
    end]
  end

  # The general approach to provide inputs for human readable
  #
  # @todo work out how to work with timezones
  #
  # @return [Hash]
  def in_general(options = {})
    remaining = @time_diff
    Hash[TIME_COMPONENTS.map do |time_component|
      if remaining > 0
        rounded_time_component = (
          remaining / 1.send(time_component).seconds
        ).round(DEFAULT_IN_OPTIONS.merge(options)[:rounding]).floor
        remaining -= rounded_time_component.send(time_component)
        [time_component, rounded_time_component]
      else
        [time_component, 0]
      end
    end]
  end

  # Returns the difference in human readable form.
  #
  # @todo I18n support
  # @todo work out how to work with timezones
  #
  # @return [String]
  def humanize(options = {})
    diff_parts = []
    in_general(options).each do |part, quantity|
      next if quantity <= 0
      part = part.to_s.humanize
      part = part.singularize if quantity <= 1
      diff_parts << "#{quantity} #{part}"
    end

    last_part = diff_parts.pop
    return last_part if diff_parts.empty?

    [diff_parts.join(', '), last_part].join(' and ')
  end

  private

  # rubocop:disable Metrics/AbcSize
  # Creates a new instance of TimeDifference
  #
  # @param [Date, Time, DateTime] start_time
  # @param [Date, Time, DateTime] end_time
  # @param [Hash] options
  # @option options [Boolean] :inclusive
  # @option options [String] :timezone
  # @option optinos [Boolean] :force_timezone
  # @return [TimeDifference]
  def initialize(start_time, end_time, options)
    start_time, end_time = end_time, start_time if end_time < start_time

    @force_timezone = options.fetch(
      :force_timezone,
      DEFAULT_DATE_OPTIONS[:force_timezone]
    )
    @inclusive = options.fetch(:inclusive, DEFAULT_DATE_OPTIONS[:inclusive])
    @timezone = options.fetch(:timezone, DEFAULT_DATE_OPTIONS[:timezone])

    end_time += 1.day if @inclusive && end_time.is_a?(Date)

    @start = in_time_zone(start_time)
    @finish = in_time_zone(end_time)

    @time_diff = (@finish.to_f - @start.to_f)
  end
  # rubocop:enable Metrics/AbcSize

  # Transforms to a timezone if needed
  #
  # @param [Date, Time, DateTime] time
  # @return [Time]
  def in_time_zone(time)
    time = time.in_time_zone(@timezone) if !time.is_a?(Time) || @force_timezone
    time
  end

  # Returns the time in seconds
  #
  # @param [Time, Date, DateTime] time
  # @return [Numeric]
  def time_in_seconds(time)
    time.to_time.to_f
  end

  # Returns the time in a given component
  #
  # @param [Symbol] component
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_component(component, options = {})
    (@time_diff / 1.send(component)).round(DEFAULT_IN_OPTIONS.merge(options)[:rounding])
  end

  # rubocop:disable Metrics/AbcSize
  # Returns the length of time of the difference in a given period_type
  #
  # @param [Symbol] period_type
  # @param [Hash] options
  # @option options [Integer] :rounding the rounding of the numbers
  # @return [Numeric]
  def in_period(period_type, options = {})
    # First step iterate through years
    periods = 0.0
    pointer = @start + 1.send(period_type)
    remainder = @time_diff
    last_number_in_s = pointer.to_f - (pointer - 1.send(period_type)).to_f

    while pointer < @finish
      periods += 1
      remainder -= last_number_in_s
      pointer += 1.send(period_type)
      last_number_in_s = pointer.to_f - (pointer - 1.send(period_type)).to_f
    end

    periods + (remainder / last_number_in_s).round(DEFAULT_IN_OPTIONS.merge(options)[:rounding])
  end
  # rubocop:enable Metrics/AbcSize

  # Returns the number of seconds in a year for a given time
  #
  # @param [Time] seconds_in_year_for_time
  # @return [Numeric]
  def seconds_in_year_for_time(time)
    ((time.beginning_of_year + 1.year) - time.beginning_of_year).to_f
  end

  # Returns the number of seconds in a year for a given time
  #
  # @param [Time] seconds_in_year_for_time
  # @return [Numeric]
  def seconds_in_month_for_time(time)
    ((time.beginning_of_month + 1.month) - time.beginning_of_month).to_f
  end
end
