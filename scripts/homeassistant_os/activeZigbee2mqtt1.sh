#!/bin/bash

zigbee2mqtt1_remote_ssh="zigbee@192.168.34.123"
zigbee2mqtt2_remote_ssh="zigbee@192.168.34.124"
zigbee2mqtt_stop_cmd="sudo rc-service zigbee2mqtt stop"
zigbee2mqtt_start_cmd="sudo rc-service zigbee2mqtt start"
snmp_server="192.168.34.103:1234"
snmp_host="homeassistant"
coordinator_port_zigbee2mqtt1="/dev/ttyUSB0"
coordinator_port_zigbee2mqtt2="/dev/ttyUSB0"
zigbee2mqtt_nvram_path="/home/zigbee/scripts/"
zigbee2mqtt_nvram_file="backup_coordinator_nvram.json"
local_aux_dir="/home/zigbee/scripts/zigbee2mqtt_config/"
local_conf_dir="/opt/zigbee2mqtt/data/"

exit_code=0

# stopping zigbee2mqtt2
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt2_remote_ssh} '${zigbee2mqtt_stop_cmd}'"
echo "$command"
if echo "$command" | bash ; then
        echo "first zigbee2mqtt2 stop ok"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "first zigbee2mqtt2 stop ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "first zigbee2mqtt2 stop error"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "first zigbee2mqtt2 stop error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
fi
# executing the command twice (Alpine service stop sometimes return a ghost error)
if echo "$command" | bash ; then
        echo "second zigbee2mqtt2 stop ok"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "second zigbee2mqtt2 stop ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "second zigbee2mqtt2 stop error"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "second zigbee2mqtt2 stop error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
fi

# stopping zigbee2mqtt1 (just in case it was already running. Required to operate with coordinator NVRAM)
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} '${zigbee2mqtt_stop_cmd}'"
echo "$command"
if echo "$command" | bash ; then
        echo "first zigbee2mqtt1 stop OK"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "first zigbee2mqtt1 stop ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "first zigbee2mqtt1 stop error"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "first zigbee2mqtt1 stop error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi
# executing the command twice (Alpine service stop sometimes return a ghost error)
if echo "$command" | bash ; then
        echo "second zigbee2mqtt1 stop OK"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "second zigbee2mqtt1 stop ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "second zigbee2mqtt1 stop error"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "second zigbee2mqtt1 stop error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi


# Retrieving NVRAM memory backup from zigbee coordinator USB dongle of zigbee2mqtt2 node (expected to be the last active node)
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt2_remote_ssh} 'source venv/bin/activate && sudo python -m zigpy_znp.tools.nvram_read ${coordinator_port_zigbee2mqtt2} -o ${zigbee2mqtt_nvram_path}${zigbee2mqtt_nvram_file} && deactivate'"
echo "$command"
if echo "$command" | bash ; then
        echo "zigbee2mqtt2 coordinator NVRAM backup OK"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt2 coordinator NVRAM backup OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
        # synchronization of coordinator NVRAM dump file from zigbee2mqtt2 to zigbee2mqtt1 node
        command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt2_remote_ssh} 'rsync -avuP ${zigbee2mqtt_nvram_path}${zigbee2mqtt_nvram_file} ${zigbee2mqtt1_remote_ssh}:${zigbee2mqtt_nvram_path}'"
        echo "$command"
        if echo "$command" | bash ; then
                echo "coordinator NVRAM backup sync to Zigbee2mqtt1 OK"
                if ! [[ -z "$snmp_server" ]]; then
                        snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator NVRAM backup sync to Zigbee2mqtt1 OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
                fi
                # cleaning memory of coordinator dongle in zigbee2mqtt1
                command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} 'source venv/bin/activate && sudo python -m zigpy_znp.tools.nvram_reset ${coordinator_port_zigbee2mqtt1} && deactivate'"
                echo "$command"
                if echo "$command" | bash ; then
                        echo "coordinator zigbee2mqtt1 NVRAM reset OK"
                        if ! [[ -z "$snmp_server" ]]; then
                                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator zigbee2mqtt1 NVRAM reset OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
                        fi
                else
                        echo "coordinator zigbee2mqtt1 NVRAM reset error"
                        exit_code=1
                        if ! [[ -z "$snmp_server" ]]; then
                                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator zigbee2mqtt1 NVRAM reset error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
                        fi
                fi

                # loading NVRAM memory backup file into zigbee2mqtt1 coordinator dongle
                command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} 'source venv/bin/activate && sudo python -m zigpy_znp.tools.nvram_write ${coordinator_port_zigbee2mqtt1} -i ${zigbee2mqtt_nvram_path}${zigbee2mqtt_nvram_file} && deactivate'"
                echo "$command"
                if echo "$command" | bash ; then
                        echo "coordinator zigbee2mqtt1 NVRAM load OK"
                        if ! [[ -z "$snmp_server" ]]; then
                                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator zigbee2mqtt1 NVRAM load OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
                        fi
                else
                        echo "coordinator zigbee2mqtt1 NVRAM load error"
                        exit_code=1
                        if ! [[ -z "$snmp_server" ]]; then
                                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator zigbee2mqtt1 NVRAM load error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
                        fi
                fi


        else
                echo "coordinator NVRAM backup sync to Zigbee2mqtt1 Error"
                exit_code=1
                if ! [[ -z "$snmp_server" ]]; then
                        snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "coordinator NVRAM backup sync to Zigbee2mqtt1 Error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
                fi
        fi


else
        echo "zigbee2mqtt2 coordinator NVRAM backup error"
        exit_code=1
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt2 coordinator NVRAM backup error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi


# Load synchronized zigbe2mqtt configuration to zigbee2mqtt1 and node startup
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} 'sudo rsync -rlpgoDcv ${local_aux_dir}* ${local_conf_dir}'"
echo "$command"
if echo "$command" | bash ; then
        echo "zigbee2mqtt1 config updated (if changed) OK"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 config updated (if changed) OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "zigbee2mqtt1 config update errror"
        exit_code=1
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 config update errror" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi

command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt1_remote_ssh} '${zigbee2mqtt_start_cmd}'"
echo "$command"
if echo "$command" | bash ; then
        echo "zigbee2mqtt1 start OK"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 start OK" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "zigbee2mqtt1 start error"
        exit_code=1
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt1 start error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi

# rebooting zigbee2mqtt2 (be sure that zigbee2mqtt is not starting automatically on startup. If it is the case, it should be disabled)
command="ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa ${zigbee2mqtt2_remote_ssh} 'sudo reboot'"
echo "$command"
if echo "$command" | bash ; then
        echo "zigbee2mqtt2 reboot ok"
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt2 reboot ok" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "OK"
        fi
else
        echo "zigbee2mqtt2 reboot error"
        exit_code=1
        if ! [[ -z "$snmp_server" ]]; then
                snmptrap -v 2c -c public "$snmp_server" '' CUSTOM-SCRIPT-MIB::netSnmpScriptResEntry CUSTOM-SCRIPT-MIB::scriptName.0 s "activeZigbee2mqtt1.sh" CUSTOM-SCRIPT-MIB::scriptHost.0 s ""$snmp_host"" CUSTOM-SCRIPT-MIB::scriptMessage.0 s "zigbee2mqtt2 reboot error" CUSTOM-SCRIPT-MIB::scriptStatus.0 s "ERR"
        fi
fi

exit $exit_code
