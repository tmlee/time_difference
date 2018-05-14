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

  describe '#in_years' do
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
