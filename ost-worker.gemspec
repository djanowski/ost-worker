require "./lib/ost/worker"

Gem::Specification.new do |s|
  s.name              = "ost-worker"
  s.version           = Ost::Worker::VERSION
  s.authors           = ["Damian Janowski"]
  s.summary           = "Workers consuming Ost queues."
  s.email             = ["djanowski@dimaion.com"]
  s.homepage          = "http://github.com/djanowski/ost-worker"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/*.*"
  ]

  s.add_dependency "ost", "~> 0.1"
end
