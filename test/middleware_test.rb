require "test/unit"
require_relative "../lib/ost/worker"

ENV["OST_TIMEOUT"] = "1"

Thread.abort_on_exception = true

class ErrorCatcher
  def self.call(item)
    begin
      yield(item)
    rescue ArgumentError
      $errors << item
      nil
    end
  end
end

class Logger
  def self.call(item)
    $jobs << item
    yield(item)
  end
end

class MiddlewareJobs < Ost::Worker
  use ErrorCatcher
  use Logger

  def self.queue
    Ost[:jobs]
  end

  def process(item)
    raise ArgumentError, "you knew it would happen"
  end
end

class OstWorkerMiddlewareTest < Test::Unit::TestCase
  def setup
    Ost[:jobs].key.del

    10.times do |i|
      Ost[:jobs] << i
    end

    $jobs = []
    $errors = []
  end

  def test_middleware
    t1 = Thread.new do
      MiddlewareJobs.run(pool: 1)
    end

    until t1.alive? && $jobs.size == 10 && $errors.size == 10
      sleep 0.2
    end

    assert_equal %w(0 1 2 3 4 5 6 7 8 9), $errors
    assert_equal %w(0 1 2 3 4 5 6 7 8 9), $jobs

    Ost.stop

    t1.join
  end
end
