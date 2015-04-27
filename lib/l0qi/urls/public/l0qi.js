var L0qi = (function() {

  var es,
      host,
      useWebSocket = false,
      ws;

  function onpic(pic) {
    var d = new Date(pic.time * 1000).toLocaleString(),
        html = '<div class="pic">' +
               d + ' - ' + pic.nick + ':<br/>' +
               '<img src="' + pic.url + '"/></div>';
    $('#pics').prepend(html);
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
    ws = new WebSocket('ws://' + host + '/pics');
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
      onpic(JSON.parse(msg.data));
    };
  };

  function createEs() {
    es = new EventSource('/pics');
    es.onopen = function(e) { 
      setEsState(es.readyState);
    };
    es.onerror = function(e) {
      console.log(e);
      status('error!', 'bad');
    };
    es.addEventListener('pic', function(e){ onpic(JSON.parse(e.data)); });
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
        onpic(h);
      });
    });
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
      connect();
      loadHistory();
    });
  };

  return {
    'init': init,
    'connection': connection
  };

})();
