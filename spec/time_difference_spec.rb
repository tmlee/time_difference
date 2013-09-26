require 'spec_helper'

describe TimeDifference do

	it "returns time difference in each component" do
		start_time = Time.new(2011,1)
		end_time = Time.new(2011,12)
		expect(TimeDifference.between(start_time, end_time).in_each_component).to eql({:years=>0.91, :months=>10.98, :weeks=>47.71, :days=>334.0, :hours=>8016.0, :minutes=>480960.0, :seconds=>28857600.0})
	end

	it "returns time difference in general that matches the total seconds" do
		start_time = Time.new(2009,9)
		end_time = Time.new(2010,11)
		expect(TimeDifference.between(start_time, end_time).in_general).to eql({:years=>1, :months=>2, :weeks=>0, :days=>0, :hours=>18, :minutes=>0, :seconds=>0})
	end

	it "returns time difference based on Wolfram Alpha" do
		start_time = Time.new(2011,1)
		end_time = Time.new(2011,12)
		expect(TimeDifference.between(start_time, end_time).in_years).to eql 0.91
		expect(TimeDifference.between(start_time, end_time).in_months).to eql 10.98
		expect(TimeDifference.between(start_time, end_time).in_weeks).to eql 47.71
		expect(TimeDifference.between(start_time, end_time).in_days).to eql 334.0
		expect(TimeDifference.between(start_time, end_time).in_hours).to eql 8016.0
		expect(TimeDifference.between(start_time, end_time).in_minutes).to eql 480960.0
	end

	it "returns time difference in absolute value regardless how it is minus-ed out" do
		start_time = Time.new(2011,1)
		end_time = Time.new(2011,12)
		expect(TimeDifference.between(end_time, start_time).in_years).to eql 0.91
		expect(TimeDifference.between(end_time, start_time).in_months).to eql 10.98
		expect(TimeDifference.between(end_time, start_time).in_weeks).to eql 47.71
		expect(TimeDifference.between(end_time, start_time).in_days).to eql 334.0
		expect(TimeDifference.between(end_time, start_time).in_hours).to eql 8016.0
		expect(TimeDifference.between(end_time, start_time).in_minutes).to eql 480960.0
	end

end