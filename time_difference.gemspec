# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["TM Lee"]
  gem.email         = ["tmlee.ltm@gmail.com"]
  gem.description   = "TimeDifference is the missing Ruby method to calculate difference between two given time. You can do a Ruby time difference in year, month, week, day, hour, minute, and seconds."
  gem.summary       = "TimeDifference is the missing Ruby method to calculate difference between two given time. You can do a Ruby time difference in year, month, week, day, hour, minute, and seconds."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "time_difference"
  gem.require_paths = ["lib"]
  gem.version       = "0.7.0"
  gem.license = 'MIT'

  gem.add_runtime_dependency('activesupport', '~> 5.1')
  gem.add_development_dependency('rspec', '~> 3.7.0')
  gem.add_development_dependency('rake')

end
