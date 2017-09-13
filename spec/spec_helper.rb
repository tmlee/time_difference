require 'rspec'
require 'time_difference'

RSpec.configure do |config|
  config.color     = true
  config.formatter = 'documentation'

  # Configure Timezone for proper tests
  ENV['TZ'] = 'UTC'
end
