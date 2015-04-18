module L0qi
  class Pics

    class Web < Angelo::Base

      port 7654
      addr '127.0.0.1'

      HOST = "l0qi.nakamura.io"

      get '/' do
        erb :index, layout: false
      end

      websocket '/pics' do |ws|
        websockets << ws
      end

      task :publish_pic do |pic|
        websockets.each {|ws| ws.write pic}
      end

    end

  end
end
