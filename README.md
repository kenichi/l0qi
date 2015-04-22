l0qi
====

### getting started

```bash
$ bundle
$ cp config.yml.template config.yml
$ $EDITOR config.yml
$ bin/l0qi (start|stop|run)
```

### config.yml

`:channels` - array of channel names
`:log_file` - file name
`:nick`     - nickname
`:plugins`  - plugin specific
`:report`   - channel for `L0qi.report 'hi'`
`:server`   - irc server

### plugins

##### karma

aliases mapped in config.yml or default alias matches anything
with existing karma to /key_*/, so that rejoin nicks like 'kenichi_',
'kenichi__' get mapped down to 'kenichi'.

##### pics

`:addr`             - address to bind angelo service to
`:port`             - port to run angelo service on
`:reload_templates` - call angelo's `reload_templates!` or not
`:ws_host`          - host to put in `ws://[host]/pics` websocket url
