require 'spec_helper'

describe TimeDifference do

	it "returns the correct time difference based on Wolfram Alpha" do
		start_time = Time.new(2011,1)
		end_time = Time.new(2011,12)
		expect(TimeDifference.between(start_time, end_time).in_years).to eql 0.91
		expect(TimeDifference.between(start_time, end_time).in_months).to eql 10.98
		expect(TimeDifference.between(start_time, end_time).in_weeks).to eql 47.71
		expect(TimeDifference.between(start_time, end_time).in_days).to eql 334.0
		expect(TimeDifference.between(start_time, end_time).in_hours).to eql 8016.0
		expect(TimeDifference.between(start_time, end_time).in_minutes).to eql 480960.0
	end

end