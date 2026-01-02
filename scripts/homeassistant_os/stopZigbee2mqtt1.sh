#!/bin/bash

zigbee2mqtt1_remote_ssh="zigbee@192.168.34.123"
zigbee2mqtt_stop_cmd="sudo rc-service zigbee2mqtt stop"
snmp_server="192.168.34.103:1234"
snmp_host="homeassistant"
exit_code=0

# stopping zigbee2mqtt1
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} '${zigbee2mqtt_stop_cmd}'"
if echo "$command" | bash ; then
        echo "zigbee2mqtt1 stop ok"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "stopzigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 stop ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "zigbee2mqtt1 stop error"
        exit_code=1
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "stopzigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 stop error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
fi

exit $exit_code
