#!/bin/bash

local_aux_dir=/home/zigbee/scripts/zigbee2mqtt_config/
remote_conf_dir=zigbee@192.168.34.123:/opt/zigbee2mqtt/data/
local_conf_dir=/opt/zigbee2mqtt/data/
local_user_name=zigbee
snmp_server=192.168.34.103:1234
snmp_host=zigbee2mqtt2
local_zigbee2mqtt_frontend_ip=192.168.34.124
remote_zigbee2mqtt_frontend_ip=192.168.34.123
exit_code=0

# syncrhonization of remote file into axiliar local dir (if the current auxiliar content is newer, it is not overwritten)
command="su -c 'rsync -avuP --exclude 'log' ${remote_conf_dir}* ${local_aux_dir}' ${local_user_name}"
if echo "$command" | bash ; then
        echo "remote sync OK"
        if ! [[ -z "$snmp_server" ]]; then
                echo "sending snmp trap result OK"
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "remote sync OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "remote sync fail"
        if ! [[ -z "$snmp_server" ]]; then
                echo "sending snmp trap result Error"
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "remote sync Fail" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
        exit_code=1
fi


# syncrhonization of local config into local dir (if the current auxiliar content is newer, it is not overwritten)
command="su -c 'rsync -avuP --exclude 'log' ${local_conf_dir}* ${local_aux_dir}' ${local_user_name}"
if echo "$command" | bash ; then
        echo "local sync OK"
	if ! [[ -z "$snmp_server" ]]; then
		echo "sending snmp trap result OK"
		snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "local sync OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
	fi
else
        echo "local sync fail"
	if ! [[ -z "$snmp_server" ]]; then
		echo "sending snmp trap result Error"
		snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "local sync Fail" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
	fi
	exit_code=1
fi

# replacement of zigbee2mqtt frontend IP into local auxiliar config dir (always updated, so file date is updated too)
command="sed -i 's/host: ${remote_zigbee2mqtt_frontend_ip}/host: ${local_zigbee2mqtt_frontend_ip}/' ${local_aux_dir}configuration.yaml"
if echo "$command" | bash ; then
        echo "config update OK"
	if ! [[ -z "$snmp_server" ]]; then
		echo "sending snmp trap result OK"
		snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "config update OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
	fi
else
        echo "config update fail"
	if ! [[ -z "$snmp_server" ]]; then
		echo "sending snmp trap result Error"
		snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "syncZigbee2mqttConfig" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "config update Fail" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
	fi
	exit_code=1
fi

exit $exit_code
