module L0qi
  class Events
    include Celluloid::IO
    include Celluloid::Logger

    DEFAULT_CHANNEL = 'events'

    attr_reader :channel

    class << self
      extend Forwardable
      def_delegator :instance, :channel

      def instance ch = nil
        @instance ||= Events.new ch
      end

      def handlers
        @handlers ||= {}
      end

      def on type
        t = type.to_sym
        handlers[t] ||= []
        if block_given?
          h = Proc.new
          raise ArgumentError unless h.arity == 1
          handlers[t] << h
        else
          handlers[t]
        end
      end

    end

    def initialize channel = nil
      @redis = ::Redis::Namespace.new :l0qi, redis: ::Redis.new(driver: :celluloid )
      @channel = channel || DEFAULT_CHANNEL
      async.sub!
    end

    def sub!
      @subscribed = true
      @redis.subscribe @channel do |on|
        on.message do |c, msg|
          begin
            msg = Angelo::SymHash.new JSON.parse msg
            Events.handlers[msg[:type].to_sym].each {|h| h[msg[:data]]}
          rescue => e
            error e.message
          end
        end
      end
    rescue => e
      error e.message
      debug 'unsubbed!'
    ensure
      @subscribed = false
    end

    def subscribed?
      @subscribed
    end

  end

  raise "couldn't create Events instance" if Events.instance.nil?
end

require 'l0qi/events/say'
