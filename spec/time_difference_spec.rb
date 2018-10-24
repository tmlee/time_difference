require 'spec_helper'

describe TimeDifference do
  def self.with_each_class(&block)
    classes = [Time, Date, DateTime]

    classes.each do |klass|
      context "with a #{klass.name} class" do
        instance_exec klass, &block
      end
    end
  end

  def self.with_each_time_class(&block)
    classes = [Time, DateTime]

    classes.each do |klass|
      context "with a #{klass.name} class" do
        instance_exec klass, &block
      end
    end
  end

  def self.with_each_date_class(&block)
    classes = [Date]

    classes.each do |klass|
      context "with a #{klass.name} class" do
        instance_exec klass, &block
      end
    end
  end

  # Let us use Australia/Sydney because it's got Daylight Savings Time
  let(:timezone) { 'Australia/Sydney' }

  describe '.between' do
    context 'options: inclusive: true' do
      with_each_class do |klass|
        it 'returns a new TimeDifference instance in each component' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time, inclusive: true))
            .to be_a(TimeDifference)
        end
      end
    end

    context 'options: timezone: Australia/Sydney' do
      with_each_class do |klass|
        it 'returns a new TimeDifference instance in each component' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          td = TimeDifference.between(start_time, end_time, timezone: timezone)

          expect(td).to be_a(TimeDifference)
        end
      end
    end

    context 'options: inclusive: true, timezone: Australia/Sydney' do
      let(:options) { { inclusive: true, timezone: timezone } }

      with_each_class do |klass|
        it 'returns a new TimeDifference instance in each component' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time, options))
            .to be_a(TimeDifference)
        end
      end
    end
  end

  describe '#time_in_seconds' do
    let(:time_diff) { TimeDifference.between(Time.parse('2017-01-01T00:00:00+00:00'), Time.parse('2017-01-02T00:00:00+00:00')) }

    it 'is 86_400' do
      expect(time_diff.send(:time_in_seconds, Time.parse('2017-01-01T00:00:00+00:00'))).to eq(1_483_228_800.0)
    end
  end

  describe '#in_each_component' do
    context 'General case' do
      with_each_class do |klass|
        it 'returns time difference in each component' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time).in_each_component)
            .to eql(
              years: 0.92,
              months: 11.0,
              weeks: 47.71,
              days: 334.0,
              hours: 8016.0,
              minutes: 480_960.0,
              seconds: 28_857_600.0
            )
        end
      end
    end

    context 'Covers a leap year' do
      with_each_class do |klass|
        it 'returns time difference in each component' do
          start_time = klass.new(2012, 1) # 2012-01-01T00:00:00Z
          end_time = klass.new(2013, 2) # 2013-02-01T00:00:00Z

          expect(TimeDifference.between(start_time, end_time).in_each_component)
            .to eql(
              years: 1.08,
              months: 13.00,
              weeks: 56.71,
              days: 397.00,
              hours: 9528.00,
              minutes: 571_680.00,
              seconds: 34_300_800.00
            )
        end
      end
    end

    context 'Covers the DST transition' do
      before { ENV['TZ'] = timezone }
      after { ENV['TZ'] = 'UTC' }

      with_each_class do |klass|
        it 'returns time difference in each component' do
          start_time = klass.parse('2018-03-29T00:00:00+11:00')
          end_time = klass.parse('2018-04-04T00:00:00+10:00')

          td = TimeDifference.between(start_time, end_time, timezone: timezone)

          expect(td.in_each_component)
            .to eql(
              years: 0.02,
              months: 0.19,
              weeks: 0.86,
              days: 6.0,
              hours: 145.0,
              minutes: 8_700.0,
              seconds: 522_000.0
            )
        end
      end
    end
  end

  describe '#in_general' do
    with_each_class do |klass|
      it 'returns time difference in general that matches the total seconds' do
        start_time = klass.new(2009, 11)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_general)
          .to eql(
            years: 1,
            months: 2,
            weeks: 0,
            days: 0,
            hours: 0,
            minutes: 0,
            seconds: 0
          )
      end
    end
  end

  describe '#humanize' do
    with_each_class do |klass|
      it 'returns a string representing the time difference from in_general' do
        start_time = klass.new(2009, 11)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).humanize)
          .to eql('1 Year and 2 Months')
      end
    end
  end

  describe '#in_calendar_years' do
    context 'default within year' do
      with_each_class do |klass|
        it 'returns time difference in years' do
          start_time = klass.new(2011, 7)
          end_time = klass.new(2011, 8)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(0.08)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 8)
          end_time = klass.new(2011, 7)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(0.08)
        end
      end
    end

    context 'default across year' do
      with_each_class do |klass|
        it 'returns time difference in years' do
          start_time = klass.new(2011, 7)
          end_time = klass.new(2012, 3)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(0.67)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2012, 3)
          end_time = klass.new(2011, 7)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(0.67)
        end
      end
    end

    context 'default long time' do
      with_each_class do |klass|
        it 'returns time difference in years' do
          start_time = klass.new(2011, 2)
          end_time = klass.new(2016, 3)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(5.08)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2016, 3)
          end_time = klass.new(2011, 2)

          expect(TimeDifference.between(start_time, end_time).in_calendar_years)
            .to eql(5.08)
        end
      end
    end

    context 'rounding: 10' do
      with_each_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time).in_years(rounding: 10))
            .to eql(0.9150684932)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)

          expect(TimeDifference.between(start_time, end_time).in_years(rounding: 10))
            .to eql(0.9150684932)
        end
      end
    end

    context 'inclusive: true' do
      with_each_date_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time, inclusive: true).in_years)
            .to eql(0.92)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)

          expect(TimeDifference.between(start_time, end_time, inclusive: true).in_years)
            .to eql(0.92)
        end
      end
    end

    context 'inclusive: true, rounding: 10' do
      with_each_date_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9178082192)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9178082192)
        end
      end
    end
  end

  describe '#in_calendar_months' do
    context 'default within month' do
      with_each_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 7, 3)
          end_time = klass.new(2011, 7, 17)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(0.45)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 7, 17)
          end_time = klass.new(2011, 7, 3)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(0.45)
        end
      end
    end

    context 'default across month' do
      with_each_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 7, 17)
          end_time = klass.new(2011, 8, 21)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(1.13)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 8, 21)
          end_time = klass.new(2011, 7, 17)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(1.13)
        end
      end
    end

    context 'default long time' do
      with_each_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 2)
          end_time = klass.new(2016, 3)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(61.0)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2016, 3)
          end_time = klass.new(2011, 2)

          expect(TimeDifference.between(start_time, end_time).in_calendar_months)
            .to eql(61.0)
        end
      end
    end

    context 'rounding: 10' do
      with_each_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_calendar_months(rounding: 10)).to eql(11.0)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_calendar_months(rounding: 10)).to eql(11.0)
        end
      end
    end

    context 'inclusive: true' do
      with_each_date_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_calendar_months).to eql(11.03)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_calendar_months).to eql(11.03)
        end
      end
    end

    context 'inclusive: true, rounding: 10' do
      with_each_date_class do |klass|
        it 'returns time difference in calendar months' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_calendar_months(rounding: 10)).to eql(11.0322580645)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_calendar_months(rounding: 10)).to eql(11.0322580645)
        end
      end
    end
  end

  describe '#in_years' do
    context 'default' do
      with_each_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)

          expect(TimeDifference.between(start_time, end_time).in_years)
            .to eql(0.92)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)

          expect(TimeDifference.between(start_time, end_time).in_years)
            .to eql(0.92)
        end
      end
    end

    context 'rounding: 10' do
      with_each_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9150684932)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9150684932)
        end
      end
    end

    context 'inclusive: true' do
      with_each_date_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_years).to eql(0.92)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)
          time_diff = TimeDifference.between(start_time, end_time)

          expect(time_diff.in_years).to eql(0.92)
        end
      end
    end

    context 'inclusive: true, rounding: 10' do
      with_each_date_class do |klass|
        it 'returns time difference in years based on Wolfram Alpha' do
          start_time = klass.new(2011, 1)
          end_time = klass.new(2011, 12)
          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9178082192)
        end

        it 'returns an absolute difference' do
          start_time = klass.new(2011, 12)
          end_time = klass.new(2011, 1)

          time_diff = TimeDifference.between(start_time, end_time, inclusive: true)

          expect(time_diff.in_years(rounding: 10)).to eql(0.9178082192)
        end
      end
    end
  end

  describe '#in_months' do
    with_each_class do |klass|
      it 'returns time difference in months based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_months)
          .to eql(11.0)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_months)
          .to eql(11.0)
      end
    end
  end

  describe '#in_weeks' do
    with_each_class do |klass|
      it 'returns time difference in weeks based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_weeks)
          .to eql(47.71)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_weeks)
          .to eql(47.71)
      end
    end
  end

  describe '#in_days' do
    with_each_class do |klass|
      it 'returns time difference in weeks based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_days)
          .to eql(334.0)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_days)
          .to eql(334.0)
      end
    end
  end

  describe '#in_hours' do
    with_each_class do |klass|
      it 'returns time difference in hours based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_hours)
          .to eql(8016.0)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_hours)
          .to eql(8016.0)
      end
    end
  end

  describe '#in_minutes' do
    with_each_class do |klass|
      it 'returns time difference in minutes based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_minutes)
          .to eql(480_960.0)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_minutes)
          .to eql(480_960.0)
      end
    end
  end

  describe '#in_seconds' do
    with_each_class do |klass|
      it 'returns time difference in seconds based on Wolfram Alpha' do
        start_time = klass.new(2011, 1)
        end_time = klass.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_seconds)
          .to eql(28_857_600.0)
      end

      it 'returns an absolute difference' do
        start_time = klass.new(2011, 12)
        end_time = klass.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_seconds)
          .to eql(28_857_600.0)
      end
    end
  end
end
