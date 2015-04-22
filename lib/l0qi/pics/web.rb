module L0qi
  class Pics

    class Web < Angelo::Base

      log_level ::Logger::DEBUG
      port CONFIG[:plugins][:pics][:web][:port]
      addr CONFIG[:plugins][:pics][:web][:addr]
      reload_templates! if CONFIG[:plugins][:pics][:web][:reload_templates]

      WEBSOCKET_PARAM = 'ws'
      HISTORY_PARAM = 'history'

      def history?
        params.has_key? HISTORY_PARAM
      end

      def history &block
        R.with {|r| r.lrange LIST_KEY, 0, LIST_MAXLEN}.each &block
      end

      get '/' do
        @use_ws = params.has_key? WEBSOCKET_PARAM
        @ws_host = CONFIG[:plugins][:pics][:web][:ws_host]
        @nick = CONFIG[:nick]
        @channels = CONFIG[:channels].join(', ')
        erb :index, layout: false
      end

      eventsource '/pics' do |es|
        sses[:pic] << es
        history {|o| es.event :pic, o} if history?
      end

      websocket '/pics' do |ws|
        websockets[:pic] << ws
        history {|o| ws.write o} if history?
      end

      task :publish_pic do |json|
        sses[:pic].event json
        websockets[:pic].each {|ws| ws.write json}
      end

    end

  end
end
