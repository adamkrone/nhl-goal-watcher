# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nhl_goal_watcher/version'

Gem::Specification.new do |spec|
  spec.name          = "nhl_goal_watcher"
  spec.version       = NhlGoalWatcher::VERSION
  spec.authors       = ["Adam Krone"]
  spec.email         = ["krone.adam@gmail.com"]
  spec.summary       = %q{Watches NHL for goal score updates, and triggers events}
  spec.description   = %q{Currently triggers Phillips Hue lights to flash red and plays an mp3 when team scores a goal.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
