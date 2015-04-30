module L0qi
  class Urls
    include Cinch::Plugin

    CONTENT_TYPE_KEY = 'Content-Type'
    LIST_KEY = 'urls:history'
    LIST_MAXLEN = CONFIG[:plugins][:urls][:history_max]
    REMINDER = 86400 / 4
    SSL_OPTS = { verify_mode: OpenSSL::SSL::VERIFY_NONE } # FIXME: eep!

    IMAGE_TYPE = 'image'
    LINK_TYPES = %w[ application text ]
    VALID_TYPES = %w[ audio video ] + LINK_TYPES + [IMAGE_TYPE]

    def initialize *a
      super
      @web = Web.run if Web.start?
      @last = Time.now - REMINDER
    end

    match /(https{0,1}:\/\/\S+)/, use_prefix: false

    def json_for m, url, type
      { channel: m.channel,
        nick: m.user.nick,
        time: Time.now.to_i,
        type: type,
        url: url
      }.to_json
    end

    def type_of url
      r = HTTP.head url, follow: true, ssl: SSL_OPTS
      if r.code == 200
        if mt = MIME::Types[r[CONTENT_TYPE_KEY]].first
          if VALID_TYPES.include? mt.media_type
            return :link if LINK_TYPES.include?(mt.media_type)
            return mt.media_type.to_sym
          end
        end
      end
      nil
    end

    def execute m, url
      if t = type_of(url)
        json = json_for m, url, t

        R.with do |r|
          r.rpush LIST_KEY, json
          r.lpop LIST_KEY if r.llen(LIST_KEY) > LIST_MAXLEN
        end

        @web.async.publish_url t, json

        if Time.now > (@last + REMINDER)
          @last = Time.now
          c = R.llen LIST_KEY
          m.reply "check out http://l0qi.nakamura.io (#{c} in history...)"
        end
      end
    end

  end
end

require 'l0qi/urls/cmd'
require 'l0qi/urls/web'
