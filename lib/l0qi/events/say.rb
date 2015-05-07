module L0qi

  Events.on :say do |data|
    Channel(data[:channel]).send(data[:text])
  end

  class << self

    def say channel, text
      data = {type: :say, data: {channel: channel, text: text}}.to_json
      R.publish Events.channel, data
    end

  end

end
