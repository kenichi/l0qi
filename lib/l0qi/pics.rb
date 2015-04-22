module L0qi
  class Pics
    include Cinch::Plugin

    CONTENT_TYPE_KEY = 'Content-Type'
    LIST_KEY = 'pics:history'
    LIST_MAXLEN = CONFIG[:plugins][:pics][:history_max]
    SSL_OPTS = { verify_mode: OpenSSL::SSL::VERIFY_NONE } # eep!
    VALID_MEDIA_TYPE = 'image'

    def initialize *a
      super
      @web = Web.run
    end

    match /(http[s]:\/\/\S+(\.gif|\.jpg|\.png))/, use_prefix: false

    def json_for m, pic
      { channel: m.channel,
        nick: m.user.nick,
        time: Time.now.to_i,
        url: pic
      }.to_json
    end

    def valid? pic
      r = HTTP.head pic, follow: true, ssl: SSL_OPTS
      if r.code == 200 && mt = MIME::Types[r[CONTENT_TYPE_KEY]].first
        mt.media_type == VALID_MEDIA_TYPE
      else
        false
      end
    end

    def execute m, pic
      if valid? pic
        json = json_for m, pic
        R.with do |r|
          r.rpush LIST_KEY, json
          r.lpop if r.llen(LIST_KEY) > LIST_MAXLEN
        end
        @web.async.publish_pic json
      end
    end

  end
end

require 'l0qi/pics/web'
