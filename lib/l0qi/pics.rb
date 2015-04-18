module L0qi
  class Pics
    include Cinch::Plugin

    def initialize *a
      super
      @web = Web.run
    end

    match /(http[s]:\/\/\S+(\.gif|\.jpg|\.png))/, use_prefix: false

    def execute m, pic
      @web.async.publish_pic pic
    end

  end
end

require 'l0qi/pics/web'
