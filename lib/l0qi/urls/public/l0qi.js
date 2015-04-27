var L0qi = (function() {

  var es,
      host,
      useWebSocket = false,
      ws;

  function dateFor(unixTime) {
    return new Date(unixTime * 1000).toLocaleString();
  };

  function prependUrl(url, cssClass, innerHTML) {
    $('#urls').prepend(
      '<div class="' + cssClass + '">' +
      dateFor(url.time) + ' - ' + url.nick + ':<br/>' +
      innerHTML + '</div>'
    );
  };

  function onImage(pic) {
    prependUrl(pic, 'pic', '<img src="' + pic.url + '"/>');
  };

  function onLink(link) {
    prependUrl(link, 'link',
               '<a target="_blank" href="' + link.url + '">' + link.url + '</a>');
  };

  function onAudio(audio) {
    prependUrl(audio, 'audio',
               '<audio controls src="' + audio.url + '"/>');
  };

  function onVideo(video) {
    prependUrl(video, 'video',
               '<video controls src="' + video.url + '"/>');
  };

  function status(s, c) {
    $('#status').html(s)
    .removeClass('ok meh bad')
    .addClass(c);
  };

  function setWsState(s) {
    switch(s) {
      case 0:
        status('Connecting...', 'meh');
        $('#connect').attr('disabled', true);
        $('input[name=kind]').attr('disabled', true);
        break;
      case 1:
        status('Open', 'ok');
        $('#connect').attr('disabled', false);
        $('#connect').attr('checked', true);
        $('input[name=kind]').attr('disabled', true);
        break;
      case 2:
        status('Closing...', 'bad');
        $('#connect').attr('disabled', true);
        $('input[name=kind]').attr('disabled', true);
        break;
      case 3:
        status('Closed', 'meh');
        $('#connect').attr('disabled', false);
        $('#connect').attr('checked', false);
        $('input[name=kind]').attr('disabled', false);
        break;
    };
  };

  function setEsState(s) {
    switch(s) {
      case 0:
        status('Connecting...', 'meh');
        $('#connect').attr('disabled', true);
        $('input[name=kind]').attr('disabled', true);
        break;
      case 1:
        status('Open', 'ok');
        $('#connect').attr('disabled', false);
        $('#connect').attr('checked', true);
        $('input[name=kind]').attr('disabled', true);
        break;
      case 2:
        status('Closed', 'meh');
        $('#connect').attr('disabled', false);
        $('#connect').attr('checked', false);
        $('input[name=kind]').attr('disabled', false);
        break;
    };
  };

  function connect() {
    if (useWebSocket) {
      createWs();
    } else {
      createEs();
    }
  };

  function createWs() {
    ws = new WebSocket('ws://' + host + '/urls');
    ws.onopen = function(e) {
      setWsState(ws.readyState);
    };
    ws.onclose = function(e) {
      setWsState(ws.readyState);
    };
    ws.onerror = function(e) {
      console.log(e);
      status('error!', 'bad');
    };
    ws.onmessage = function(msg) {
      handleMessageData(JSON.parse(msg.data));
    };
  };

  function handleMessageData(d) {
    switch (d.type) {
      case "image":
        onImage(d);
        break;
      case "link":
        onLink(d);
        break;
      case "audio":
        onAudio(d);
        break;
      case "video":
        onVideo(d);
        break;
    }
  };

  function createEs() {
    es = new EventSource('/urls');
    es.onopen = function(e) { 
      setEsState(es.readyState);
    };
    es.onerror = function(e) {
      console.log(e);
      status('error!', 'bad');
    };
    es.addEventListener('image', function(e){ onImage(JSON.parse(e.data)); });
    es.addEventListener('link', function(e){ onLink(JSON.parse(e.data)); });
    es.addEventListener('audio', function(e){ onAudio(JSON.parse(e.data)); });
    es.addEventListener('video', function(e){ onVideo(JSON.parse(e.data)); });
  };

  function connection() {
    return useWebSocket ? ws : es;
  };

  function handleConnectClick(e) {
    if ($('#connect').is(':checked')) {
      connect();
    } else {
      connection().close();
      if (!useWebSocket) setEsState(es.readyState);
    }
  };

  function handleKindClick(e) {
    useWebSocket = document.kind.kind.value == 'ws';
  };

  function loadHistory() {
    $.get('/history', function(hs) {
      $.each(hs, function(i, h) {
        handleMessageData(h);
      });
    });
  };

  function toggleImages(b) {
    var is = $('.pic img');
    if (b) is.show();
    else   is.hide();
  };

  function init(_host, _useWebSocket, history) {
    host = _host;

    // if '?ws' was not requested, useWebSocket defaults to false but
    // some browsers don't support SSE yet, so check for EventSource
    // and "degrade" to WebSocket.
    //
    useWebSocket = _useWebSocket || !(window.hasOwnProperty('EventSource'));

    $(document).ready(function() {
      document.kind.kind.value = useWebSocket ? 'ws' : 'es';

      $('input[name=kind]').on('click', handleKindClick);
      $('#connect').on('click', handleConnectClick);

      // save some cpu & power
      window.onblur = function(){ toggleImages(false); };
      window.onfocus = function(){ toggleImages(true); };

      connect();
      loadHistory();
    });
  };

  return {
    'init': init,
    'connection': connection
  };

})();
