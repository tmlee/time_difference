require 'rspec'
require 'time_difference'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'

  # Configure Timezone for proper tests
  ENV['TZ'] = 'UTC'
end