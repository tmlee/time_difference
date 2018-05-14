require 'rspec'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)
SimpleCov.start

require 'time_difference'

RSpec.configure do |config|
  config.formatter = 'documentation'

  # Configure Timezone for proper tests
  ENV['TZ'] = 'UTC'
end
