module L0qi
  class Pics

    class Web < Angelo::Base

      log_level ::Logger::DEBUG
      port CONFIG[:plugins][:pics][:web][:port]
      addr CONFIG[:plugins][:pics][:web][:addr]
      reload_templates! if CONFIG[:plugins][:pics][:web][:reload_templates]

      WEBSOCKET_PARAM = 'ws'

      FSM = Class.new do
        include Celluloid::FSM
        default_state :not_pinging
        state :pinging
      end

      get '/' do
        @use_ws = params.has_key? WEBSOCKET_PARAM
        @ws_host = CONFIG[:plugins][:pics][:web][:ws_host]
        erb :index, layout: false
      end

      get '/history' do
        content_type :json
        R.lrange(LIST_KEY, 0, LIST_MAXLEN).map {|p| JSON.parse p}
      end

      eventsource '/pics' do |es|
        sses[:pic] << es
        async :ping_sses
      end

      websocket '/pics' do |ws|
        websockets[:pic] << ws
      end

      task :publish_pic do |json|
        sses[:pic].event json
        websockets[:pic].each {|ws| ws.write json}
      end

      task :ping_sses do
        @fsm ||= FSM.new self
        if @fsm.state == :not_pinging
          begin
            @fsm.transition :pinging
            every(@base.ping_time) do
              sses[:pic].each {|es| es.event :ping}
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
