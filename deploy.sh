#!/bin/bash

cd /var/lib/hubot
git pull
npm install
service hubot stop
service hubot start
