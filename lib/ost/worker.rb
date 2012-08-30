require "ost"

class Ost::Worker
  VERSION = "0.0.1"

  def self.use(middleware)
    self.middleware << middleware
  end

  def self.middleware
    @middleware ||= []
  end

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
      chain.call(item)
    end
  end

  def process(item)
    raise NotImplementedError
  end

  def chain
    chain = self.class.middleware.dup

    chain << -> *args { process(*args) }

    traverse = -> *args do
      if e = chain.shift
        e.call(*args, &traverse)
      end
    end
  end
end
