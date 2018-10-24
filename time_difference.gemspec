
Gem::Specification.new do |gem|
  gem.authors       = ['TM Lee', 'Joel Courtney']
  gem.email         = ['tmlee.ltm@gmail.com', 'jcourtney@cozero.com.au']
  gem.description   = 'TimeDifference is the missing Ruby method to calculate '\
                      'difference between two given time. You can do a Ruby '\
                      'time difference in year, month, week, day, hour, '\
                      'minute, and seconds.'
  gem.summary       = 'TimeDifference is the missing Ruby method to calculate '\
                      'difference between two given time. You can do a Ruby '\
                      'time difference in year, month, week, day, hour, '\
                      'minute, and seconds.'
  gem.homepage      = 'https://github.com/tmlee/time_difference'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'time_difference'
  gem.require_paths = ['lib']
  gem.version       = '0.8.0'
  gem.license = 'MIT'

  gem.add_runtime_dependency('activesupport', '>= 4.2.6', '< 5.3')
  gem.add_development_dependency('coveralls')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec', '~> 3.7.0')
  gem.add_development_dependency('simplecov')
end
