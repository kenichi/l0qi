require 'tilt/erb'

module L0qi
  class Urls

    class Web < Angelo::Base

      addr CONFIG[:plugins][:urls][:web][:addr]
      log_level ::Logger::DEBUG
      port CONFIG[:plugins][:urls][:web][:port]
      reload_templates! if CONFIG[:plugins][:urls][:web][:reload_templates]

      HISTORY_FMT = '[%s]'
      WEBSOCKET_PARAM = 'ws'
      RELOAD_EVENT_TYPE = 'reload'
      RELOAD_TOKEN = CONFIG[:plugins][:urls][:web][:reload_token]

      # ---

      class << self

        def start!
          @start = true
        end

        def dont_start!
          @start = false
        end

        def start?
          @start.nil? || @start
        end

        def on_ws_messages key = nil
          @on_ws_messages ||= {}
          case key
          when NilClass
            @on_ws_messages
          when Symbol
            @on_ws_messages[key] ||= []
          end
        end

      end

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

      post '/reload' do
        if RELOAD_TOKEN == params[:token]
          content_type :json

          d = { in: params[:in].to_i, message: params[:message] }
          sses[:url].each {|es| es.event :reload, d}

          d.merge! type: RELOAD_EVENT_TYPE
          websockets[:url].each {|ws| ws.write d.to_json}

          {reload: :queued}
        else
          halt 404
        end
      end

      eventsource '/urls' do |es|
        sses[:url] << es
        async :ping_sses
      end

      websocket '/urls' do |ws|
        websockets[:url] << ws
        ws.on_message do |msg|
          begin
            msg = JSON.parse msg
            Web.on_ws_messages(:url).each {|on| on[ws, msg]}
          rescue => e
            warn e.message
          end
        end
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
