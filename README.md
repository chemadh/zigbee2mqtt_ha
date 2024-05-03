# Zigbee2mqtt High-Avaliability controller prototype

## Introduction

High Availability controller prototype for two zigbee2mqtt instances with independent USB zigbee dongles (specifically implemented for Sonoff ZBDongle-P). The final purpose is enabling that one of the zigbee2mqtt could play the "active" role, meanwhile the second is in "stand-by" status for a single zigbee network (enabling also an automated switch over to stand-by node in case of detecting problems in the active instance). Please note that zigbee standard only allows to define a single coordinator node, so the only available high-availability model to use is active-stand by. Detailed features:

- __Automatic synchronization of zigbe2mqtt configuration and data files__ from active to stand-by instance, to ensure an up-to-date zigbee and mqtt interactions in case of active to stand-by switch over is triggered.
- __Automatic synchronization of Sonoff ZDonble-P coordinator Non-Volatile RAM__ from active to stand-by instance, in each zigbee2mqtt node where the dongle is connected to. It enables a seamless change of zigbee coordinator from active to stand-by node when required (avoiding impact on the rest of zigbee nodes, not requiring to re-join them to the network).
- __Control point enabled in a third node__ where MQTT broker is working, to detect issues with active zigbmee2mqtt instance and trigger the switch-over to change service to stanby-by node. The prototype includes the automated management of this control point in a Home Assistant instance with MQTT component configured

The overall design is shown following diagram:

<img src="./zigbee2mqtt_ha_architecture.PNG" title="zigbee2mqtt HA architecture" width=800px></img>

## Environment details

Find below some relevant details about the validation environment used. In case of using a diferent environment, it could be required to make some minor adaptations in the scripts provided:

- __Zigbee coordinators (2x)__: Sonoff ZBDongle-P. In case of using a different one, it could involve to change the commands to read and write non volatile memory in the dongles.
- __Zigbee2mqtt nodes (2x)__: usage of up-to-date Alpine Linux distribution to execute zigbee2mqtt service (https://www.zigbee2mqtt.io/). Zigbee2mqtt application is deployed and started and stopped using Alpine service commands defined for that purpose. In case of using a different distribution, some minor changes could be required for remote start and stop of zigbee2mqtt from controlling scripts.
  - Example of Alpine service content of /etc/init.d/zigbee2mqtt to start and stop the application with rc-service command: https://github.com/chemadh/zigbee2mqtt_ha/blob/main/zigbee2mqtt_alpine_service_example . __The zigbee2mqtt service should NOT be launched on node startup, otherwise the HA control prototype will not work properly__.
  - Alpine linux user is expected to allow sudo, to allow access to linux service scripts to start and stop zigbee2mqtt, as well as allowing zigpy-znp to access to dongle USB port.
- __MQTT broker node__: Usage of Linux Debian distribution for High-Availability control script execution. Home assistant containing the MQTT broker component communicating with Zigbee2mqtt deployed in Docker mode in the same Linux node. No impact expected by using a different Linux distribution. Some referrence instructions:
  - Home Assistant supervised setup: https://community.home-assistant.io/t/installing-home-assistant-supervised-using-debian-12/200253
  - Installation of Mosquitto broker Home Assitant component:  https://www.home-assistant.io/integrations/mqtt

Common components used in the nodes previously defined:

- __Linux packages__: rsync, snmp (net-snmp-tools for Alpine; snmpd, snmp, libsnmp-dev, for Debian).
  - In addition to this, specifically for zigbee2mqtt nodes: python3, py3-pip. Instalation of zigpy-znp python component (pip install zigpy-znp). Aditional info in this link: https://github.com/zigpy/zigpy-znp/blob/0cacf7a51d205ac3a19acde10a8115cf5ac36ce1/TOOLS.md
- __NTPD or Timesyncd__ time sinchronization service to be active in each node to ensure a correct syncrhonization of most recent files. It can be skipped if the nodes are virtualized and obtaining time reference from a hypervisor cluster (like Proxmox Virtual Environment - https://pve.proxmox.com/wiki/Main_Page -). 
- __SNMP MIBs__: The scripts notify about execution results using SNMP traps. The MIBs to be incluided in each linux node using the proposed scripts are stored in https://github.com/chemadh/zigbee2mqtt_ha/tree/main/MIBs . In case of no monitoring system available in your installation, it is still recommended to install the SNMP packages and MIBs to avoid script execution errors (no matter if the SNMP traps are not finally attended by any agent).
- __Enable remote ssh connection__ between components (MQTT broker and zigbee2mqtt nodes) without interactive credentials. Some example instructions here: https://www.thegeekdiary.com/how-to-run-scp-without-password-prompt-interruption-in-linux/

__Zigbee dongle configuration__:

- Zigbee IEEE address of active Zigbee coordinator (Sonoff ZBDongle-P) must be flashed as secondary IEEE address of the stand-by Zigbee coordinator. It is required to be identified as the same node by the rest of the zigbee network when the service is switched-over between coordinators. Please note that some of the flashing tools only shows the primary IEEE address, but it doesn't mean that the secondary address is efectively updated. Some guides below to update firmware, read and write IEEE address in Sonoff ZBDongle-P:
  - https://sonoff.tech/wp-content/uploads/2021/12/SONOFF-Zigbee-3.0-USB-dongle-plus-firmware-flashing-1-1.pdf
  - https://www.zigbee2mqtt.io/guide/adapters/flashing/copy_ieeaddr.html
  - https://github.com/JelmerT/cc2538-bsl

## Scripts for synchronization of configuration files from active to stand-by zigbee2mqtt

Each zigbee2mqtt High-Availability instance needs to synchronize the configuration files from active to stand-by instances. The following scripts to be deployed in each zigbee2mqtt instance are shared to achieve it:

- [/scripts/zigbee2mqtt1/syncZigbee2mqttConfig.sh](./scripts/zigbee2mqtt1/syncZigbee2mqttConfig.sh)
- [/scripts/zigbee2mqtt2/syncZigbee2mqttConfig.sh](./scripts/zigbee2mqtt2/syncZigbee2mqttConfig.sh)

The both files defines the same logic, with different example configuration for local and remote zigbee2mqtt nodes parameters. The first lines in each script contains the configuration variables to be updated to each environment. Explanation of each parameter, below:

- __local_aux_dir__: Path of the local zigbee2mqtt instance directory where the up-to-date active configuration files will be stored. Example value: /home/zigbee/scripts/zigbee2mqtt_config/
- __remote_conf_dir__: SSH path (including IP and username) to the remote instance directory where the Zigbee2mqtt application reads and updates the configuration when it is active. Example value: zigbee@192.168.34.124:/opt/zigbee2mqtt/data/
- __local_conf_dir__: Path of the local instance directory where the Zigbee2mqtt application reads and updates the configuration when it is active. Example value: /opt/zigbee2mqtt/data/
- __local_user_name__: Linux username to execute rsync command. It should be enabled to execute SSH over remote zigbee2mqtt node without interactive credentials. Example value: zigbee
- __snmp_server__: SNMP server where the script will send SNMP traps (v2) notifying about the result of the execution. If this functionality is not required, the value of the variable should be leaved empty. Example value: 192.168.34.103:1234
- __snmp_host__: Source SNMP host of the trap, following the MIB defined for this purpose. It can be left empty if the SNMP functionality is not required. Example value: zigbee2mqtt1
- __local_zigbee2mqtt_frontend_ip__: Zigbee2mqtt normally uses a web frontend to enable application operation. Since the web frontend IP is defined in the configuration files, it is required to be updated when synchronizing the configuration files between different nodes. This parameter defines de local zigbee2mtt instance web frontend IP. Example value: 192.168.34.123
- __remote_zigbee2mqtt_frontend_ip__: The same as the parameter above, but in this case, referring to the remote zigbee2mqtt instance web frontend IP. Example value: 192.168.34.124

## Scripts for Zigbee2mqtt High-Availability centralized control

A third node will control the active to stand-by failover zigbee2mqtt coordinator, whose configuration is synchronized using the mechanism defined above. It makes sense that this third node should be the MQTT broker node (like Mosqitto runing in Home Assistant enviornment), since this element will be notified in case the communication with active zigbee2mqtt fails. The following set of scripts are provided for this purpose:

### [ping_mqtts.sh](./scripts/homeAssistant/ping_mqtts.sh)

Script to check connectivity from controller to both zigbee2mqtt intances. It is intended to check connectivity with both nodes before making an scheduled active to stand-by switchover. The first lines in the script contains the configuration variables to be updated for each environment. Explanation of each parameter, below:

- __zigbee2mqtt1_IP__: IP of first zigbee2mqtt instance. Example value: 192.168.34.123
- __zigbee2mqtt2_IP__: IP of second zigbee2mqtt instance. Example value: 192.168.34.124
- __snmp_server__: SNMP server where the script will send SNMP traps (v2) notifying about the result of the execution. If this functionality is not required, the value of the variable should be leaved empty. Example value: 192.168.34.103:1234
- __snmp_host__: Source SNMP host of the trap, following the MIB defined for this purpose. It can be left empty if the SNMP functionality is not required. Example value: homeassistant

### [stopZigbee2mqtt1.sh](./scripts/homeAssistant/stopZigbee2mqtt1.sh) / [stopZigbee2mqtt2.sh](./scripts/homeAssistant/stopZigbee2mqtt2.sh) 

Couple of scritps to stop remotely each zigbee2mqtt instance. Used by the controller node to initiate a manual switchover between active and stand-by nodes, when MQTT can detect service interruption in the active zigbee2mqtt node. The first lines in the script contains the configuration variables to be updated for each environment. Explanation of each parameter, below:

- __zigbee2mqtt1_remote_ssh__ / __zigbee2mqtt2_remote_ssh__ (Depending on the script for each zigbee2mqtt instance): SSH user and IP to use for remote connection with the zigbee2mqtt node. The user should be previously configured to disable interactive login. Example value: "zigbee@192.168.34.123"
- __zigbee2mqtt_stop_cmd__: Remote stop command to execute in the remote SSH session to stop de zigbee2mqtt instance. In the case of using an Alipine Linux distribution like in this prototype, the following can be used: "sudo rc-service zigbee2mqtt stop"
- __snmp_server__: SNMP server where the script will send SNMP traps (v2) notifying about the result of the execution. If this functionality is not required, the value of the variable should be leaved empty. Example value: 192.168.34.103:1234
- __snmp_host__: Source SNMP host of the trap, following the MIB defined for this purpose. It can be left empty if the SNMP functionality is not required. Example value: homeassistant

### [activeZigbee2mqtt1.sh](./scripts/homeAssistant/activeZigbee2mqtt1.sh) / [activeZigbee2mqtt2.sh](./scripts/homeAssistant/activeZigbee2mqtt2.sh)



## Usage of High-Availability control scripts from Home Assistant

## Possible further improvements


