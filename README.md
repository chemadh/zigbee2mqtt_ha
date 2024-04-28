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
  - Example of Alpine service content of /etc/init.d/zigbee2mqtt to start and stop the application with rc-service command: https://github.com/chemadh/zigbee2mqtt_ha/blob/main/zigbee2mqtt_alpine_service_example
  - Alpine linux user is expected to allow sudo, to allow zigpy-znp to access to dongle USB port.
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

## Scripts for Zigbee2mqtt High-Availability centralized control

## Usage of High-Availability control scripts from Home Assistant

## Possible further improvements


