module L0qi
  class Done
    include Cinch::Plugin

    REPLIES = [ 'fascinating.',
                'tell me more.',
                'really? go on.',
                'i can do this all day.' ]

    match /(done|doing).*/

    def execute m
      m.reply REPLIES[rand(REPLIES.length)]
    end

  end
end
