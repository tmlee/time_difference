require 'spec_helper'

describe TimeDifference do

  def self.with_each_class(&block)
    classes = [Time, Date, DateTime]

    classes.each do |clazz|
      context "with a #{clazz.name} class" do
        instance_exec clazz, &block
      end
    end
  end

  describe ".between" do
    with_each_class do |clazz|
      it "returns a new TimeDifference instance in each component" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time)).to be_a(TimeDifference)
      end
    end
  end

  describe "#in_each_component" do
    with_each_class do |clazz|
      let(:result) {
        if TimeDifference::SI_BASE_UNIT
          {:years=>0.91, :months=>10.97, :weeks=>47.71, :days=>334.0, :hours=>8016.0, :minutes=>480960.0, :seconds=>28857600.0}
        else
          {years: 0.91, months: 10.98, weeks: 47.71, days: 334.0, hours: 8016.0, minutes: 480960.0, seconds: 28857600.0}
        end
      }
      it "returns time difference in each component" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)
        expect(TimeDifference.between(start_time, end_time).in_each_component).to eql(result)
      end
    end
  end

  describe "#in_general" do
    with_each_class do |clazz|
      let(:result) {
        if TimeDifference::SI_BASE_UNIT
           {:years=>1, :months=>1, :weeks=>4, :days=>2, :hours=>7, :minutes=>41, :seconds=>42}
        else
          {:years=>1, :months=>2, :weeks=>0, :days=>0, :hours=>18, :minutes=>0, :seconds=>0}
        end
      }
      it "returns time difference in general that matches the total seconds" do
        start_time = clazz.new(2009, 11)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_general).to eql(result)
      end
    end
  end

  describe "#humanize" do
    let(:result) { TimeDifference::SI_BASE_UNIT ? "1 Year, 1 Month, 4 Weeks, 2 Days, 7 Hours, 41 Minutes and 42 Seconds" : "1 Year, 2 Months and 18 Hours" }
    with_each_class do |clazz|
      it "returns a string representing the time difference from in_general" do
        start_time = clazz.new(2009, 11)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).humanize).to eql(result)
      end
    end
  end

  describe "#in_years" do
    with_each_class do |clazz|
      it "returns time difference in years based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_years).to eql(0.91)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_years).to eql(0.91)
      end
    end
  end

  describe "#in_months" do
    with_each_class do |clazz|
      let(:result) { TimeDifference::SI_BASE_UNIT ? 10.97 : 10.98 }
      it "returns time difference in months based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_months).to eql(result)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_months).to eql(result)
      end
    end
  end

  describe "#in_weeks" do
    with_each_class do |clazz|
      it "returns time difference in weeks based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_weeks).to eql(47.71)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_weeks).to eql(47.71)
      end
    end
  end

  describe "#in_days" do
    with_each_class do |clazz|
      it "returns time difference in weeks based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_days).to eql(334.0)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_days).to eql(334.0)
      end
    end
  end

  describe "#in_hours" do
    with_each_class do |clazz|
      it "returns time difference in hours based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_hours).to eql(8016.0)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_hours).to eql(8016.0)
      end
    end
  end

  describe "#in_minutes" do
    with_each_class do |clazz|
      it "returns time difference in minutes based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_minutes).to eql(480960.0)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_minutes).to eql(480960.0)
      end
    end
  end

  describe "#in_seconds" do
    with_each_class do |clazz|
      it "returns time difference in seconds based on Wolfram Alpha" do
        start_time = clazz.new(2011, 1)
        end_time = clazz.new(2011, 12)

        expect(TimeDifference.between(start_time, end_time).in_seconds).to eql(28857600.0)
      end

      it "returns an absolute difference" do
        start_time = clazz.new(2011, 12)
        end_time = clazz.new(2011, 1)

        expect(TimeDifference.between(start_time, end_time).in_seconds).to eql(28857600.0)
      end
    end
  end
end
