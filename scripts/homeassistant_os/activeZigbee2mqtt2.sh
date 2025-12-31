#!/bin/bash

ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa -f root@192.168.34.130 'rm /config/sh/result.log; nohup /config/sh/remote/activeZigbee2mqtt2.sh >/config/sh/result.log 2>&1 </dev/null &'

#ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa -f domo@192.168.34.125 'rm ./scripts/result.log; nohup ./scripts/longExecTimeScript.sh >./scripts/result.log 2>&1 </dev/null &'

#ejecutando en background para evitar cancelación de script por timeout en homeassistant 
#cd /config/sh/
#rm ./nohup.out
#nohup ./activeZigbee2mqtt2_background.sh & disown
