require 'tilt/erb'

module L0qi
  class Urls

    class Web < Angelo::Base

      addr CONFIG[:plugins][:urls][:web][:addr]
      log_level ::Logger::DEBUG
      port CONFIG[:plugins][:urls][:web][:port]
      reload_templates! if CONFIG[:plugins][:urls][:web][:reload_templates]

      WEBSOCKET_PARAM = 'ws'
      HISTORY_FMT = '[%s]'

      # ---

      get '/' do
        @use_ws = params.has_key? WEBSOCKET_PARAM
        erb :index, layout: false
      end

      get '/history' do
        content_type :json
        urls = R.lrange LIST_KEY, 0, (LIST_MAXLEN - 1)
        HISTORY_FMT % urls.join(',')
      end

      eventsource '/urls' do |es|
        sses[:url] << es
        async :ping_sses
      end

      websocket '/urls' do |ws|
        websockets[:url] << ws
      end

      # ---

      class FSM
        include Celluloid::FSM
        default_state :not_pinging
        state :pinging
      end

      # ---

      task :publish_url do |type, json|
        sses[:url].event type, json
        websockets[:url].each {|ws| ws.write json}
      end

      task :ping_sses do
        @fsm ||= FSM.new self
        if @fsm.state == :not_pinging
          begin
            @fsm.transition :pinging
            every(@base.ping_time) do
              sses[:url].each {|es| es.event :ping}
            end
          rescue => e
            error e.message
          ensure
            @fsm.transition :not_pinging
          end
        end
      end

    end

  end
end
