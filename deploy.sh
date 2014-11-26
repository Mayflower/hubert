#!/bin/bash

(tail -n1 <&0 | jq '.ref' | grep '/master' >/dev/null 2>&1) || exit 1

deploy() {
  cd /var/lib/hubot
  git pull

  npm install

  # FIXME
  # calling stop/start because restart will
  # result in multiple hubot instances ...
  service hubot stop
  service hubot start
}

(deploy &) >/dev/null 2>&1

trap "{ printf 'HTTP/1.1 200\r\n\r\nThanks, bro.\n'; exit 0; }" EXIT
