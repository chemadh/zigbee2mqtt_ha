#!/bin/bash

zigbee2mqtt1_IP=192.168.34.123
zigbee2mqtt2_IP=192.168.34.124
snmp_server=192.168.34.103:1234
snmp_host=homeassistant

exit_code=0

if ping -c 1 "$zigbee2mqtt1_IP" &> /dev/null
then
  if ping -c 1 "$zigbee2mqtt2_IP" &> /dev/null
  then
    echo "success"
    if ! [[ -z "$snmp_server" ]]; then
      # echo "sending snmp trap result OK"
      snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "ping_mqtts.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "ping success" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
    fi
  else
    echo "error mqtt2"
    exit_code=1
    if ! [[ -z "$snmp_server" ]]; then
      # echo "sending snmp trap result Error"
      snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "ping_mqtts.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "ping error mqtt2" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
    fi
  fi
else
  echo "error mqtt1"
  exit_code=1
  if ! [[ -z "$snmp_server" ]]; then
    # echo "sending snmp trap result Error"
    snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "ping_mqtts.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "ping error mqtt1" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
  fi
fi

exit $exit_code
