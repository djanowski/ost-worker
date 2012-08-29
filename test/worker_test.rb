require "test/unit"
require_relative "../lib/ost/worker"

ENV["OST_TIMEOUT"] = "1"

Thread.abort_on_exception = true

class Jobs < Ost::Worker
  def self.queue
    Ost[:jobs]
  end

  def process(id)
    $jobs << [id, Thread.current.object_id]
    sleep 0.5
  end
end

class OstWorkerTest < Test::Unit::TestCase
  def setup
    Ost[:jobs].key.del

    10.times do |i|
      Ost[:jobs] << i
    end

    $jobs = []
  end

  def test_worker
    t1 = Thread.new do
      Jobs.run
    end

    until t1.alive? && $jobs.size == 10
      sleep 0.2
    end

    assert_equal %w(0 1 2 3 4 5 6 7 8 9), $jobs.map(&:first)
    assert_equal 1, $jobs.map(&:last).uniq.size

    Ost.stop

    t1.join
  end

  def test_worker_pool
    t1 = Thread.new do
      Jobs.run(pool: 3)
    end

    until t1.alive? && $jobs.size == 10
      sleep 0.2
    end

    assert_equal %w(0 1 2 3 4 5 6 7 8 9), $jobs.map(&:first)
    assert_equal 3, $jobs.map(&:last).uniq.size

    Ost.stop

    t1.join
  end
end
