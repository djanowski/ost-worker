require "ost"

class Ost::Worker
  VERSION = "0.0.1"

  def self.run(options = {})
    size = options.fetch(:pool, 1)

    pool = Array.new(size) do
      Thread.new do
        new.run
      end
    end

    pool.each { |p| p.join }
  end

  def queue
    self.class.queue
  end

  def run
    queue.each do |item|
      process(item)
    end
  end

  def process(item)
    raise NotImplementedError
  end
end
