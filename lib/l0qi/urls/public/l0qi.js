var L0qi = (function() {

  var es,
      useWebSocket = false,
      ws;

  var ES = {

    create: function() {
      es = new EventSource('/urls');
      es.onopen = function(e) { 
        ES.setState(es.readyState);
      };
      es.onerror = function(e) {
        console.log('EventSource error:', e);
        UI.status('error!', 'bad');
      };
      es.addEventListener('image', function(e){ On.image(JSON.parse(e.data)); });
      es.addEventListener('link', function(e){ On.link(JSON.parse(e.data)); });
      es.addEventListener('audio', function(e){ On.audio(JSON.parse(e.data)); });
      es.addEventListener('video', function(e){ On.video(JSON.parse(e.data)); });
    },

    setState: function(s) {
      switch(s) {
        case 0:
          UI.status('Connecting...', 'meh');
          $('#connect').attr('disabled', true);
          $('input[name=kind]').attr('disabled', true);
          break;
        case 1:
          UI.status('Open', 'ok');
          $('#connect').attr('disabled', false);
          $('#connect').attr('checked', true);
          $('input[name=kind]').attr('disabled', true);
          break;
        case 2:
          UI.status('Closed', 'meh');
          $('#connect').attr('disabled', false);
          $('#connect').attr('checked', false);
          $('input[name=kind]').attr('disabled', false);
          break;
      };
    }

  };

  var On = {

    audio: function(audio) {
      UI.prependUrl(audio, 'audio', '<audio controls src="' + audio.url + '"/>');
    },

    image: function(pic) {
      var id = pic.nick + pic.time;
      UI.prependUrl(pic, 'pic', '<img id="' + id + '" src="' + pic.url + '"/>');
    },

    link: function(link) {
      UI.prependUrl(link, 'link', '<a target="_blank" href="' + link.url + '">' + link.url + '</a>');
    },

    messageData: function(d) {
      On[d.type](d);
    },

    video: function(video) {
      UI.prependUrl(video, 'video', '<video controls src="' + video.url + '"/>');
    }

  };

  var WS = {
    
    create: function() {
      var scheme = 'ws';
      if (window.location.protocol == 'https:') scheme += 's';
      ws = new WebSocket(scheme + '://' + window.location.host + '/urls');
      ws.onopen = function(e) {
        WS.setState(ws.readyState);
      };
      ws.onclose = function(e) {
        WS.setState(ws.readyState);
      };
      ws.onerror = function(e) {
        console.log('WebSocket error:', e);
        UI.status('error!', 'bad');
      };
      ws.onmessage = function(msg) {
        On.messageData(JSON.parse(msg.data));
      };
    },

    setState: function(s) {
      switch(s) {
        case 0:
          UI.status('Connecting...', 'meh');
          $('#connect').attr('disabled', true);
          $('input[name=kind]').attr('disabled', true);
          break;
        case 1:
          UI.status('Open', 'ok');
          $('#connect').attr('disabled', false);
          $('#connect').attr('checked', true);
          $('input[name=kind]').attr('disabled', true);
          break;
        case 2:
          UI.status('Closing...', 'bad');
          $('#connect').attr('disabled', true);
          $('input[name=kind]').attr('disabled', true);
          break;
        case 3:
          UI.status('Closed', 'meh');
          $('#connect').attr('disabled', false);
          $('#connect').attr('checked', false);
          $('input[name=kind]').attr('disabled', false);
          break;
      };
    }

  };

  var UI = {

    Click: {

      connect: function(e) {
        if ($('#connect').is(':checked')) {
          connect();
        } else {
          connection().close();
          if (!useWebSocket) ES.setState(es.readyState);
        }
      },

      kind: function(e) {
        useWebSocket = document.kind.kind.value == 'ws';
      }

    },

    prependUrl: function(url, cssClass, innerHTML) {
      $('#urls').prepend(
        '<div class="' + cssClass + '">' +
        Util.dateFor(url.time) + ' - ' + url.nick + ':<br/>' +
        innerHTML + '</div>'
      );
    },

    status: function(s, c) {
      $('#status').html(s)
      .removeClass('ok meh bad')
      .addClass(c);
    },

    toggleImages: function(b) {
      var is = $('.pic img');
      if (b) is.show();
      else   is.hide();
    }

  };

  var Util = {

    dateFor: function(unixTime) {
      return new Date(unixTime * 1000).toLocaleString();
    }

  };

  function connect() {
    if (useWebSocket) {
      WS.create();
    } else {
      ES.create();
    }
  };

  function connection() {
    return useWebSocket ? ws : es;
  };

  function loadHistory() {
    $.get('/history', function(hs) {
      $.each(hs, function(i, h) {
        On.messageData(h);
      });
    });
  };

  function init(_useWebSocket) {

    // save some cpu & power
    window.onblur = function(){ UI.toggleImages(false); };
    window.onfocus = function(){ UI.toggleImages(true); };

    // if '?ws' was not requested, useWebSocket defaults to false but
    // some browsers don't support SSE yet, so check for EventSource
    // and "degrade" to WebSocket.
    //
    useWebSocket = _useWebSocket || !(window.hasOwnProperty('EventSource'));
    if (useWebSocket != _useWebSocket) {
      console.log('could not find EventSource, using WebSocket');
    }

    $(document).ready(function() {
      document.kind.kind.value = useWebSocket ? 'ws' : 'es';

      $('input[name=kind]').on('click', UI.Click.kind);
      $('#connect').on('click', UI.Click.connect);

      connect();
      loadHistory();
    });
  };

  return {
    'init': init,
    'connection': connection
  };

})();
