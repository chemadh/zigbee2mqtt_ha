# Zigbee2mqtt High-Avaliability controller prototype

## Introduction

High Availability controller prototype for two zigbee2mqtt instances with independent USB zigbee dongles (specifically implemented for Sonoff ZBDongle-P). The final purpose is enabling that one of the zigbee2mqtt could play the "active" role, meanwhile the second is in "stand-by" status for a single zigbee network (enabling also an automated switch over to stand-by node in case of detecting problems in the active instance). Please note that zigbee standard only allows to define a single coordinator node, so the only available high-availability model to use is active-stand by. Detailed features:

- __Automatic synchronization of zigbe2mqtt configuration and data files__ from active to stand-by instance, to ensure an up-to-date zigbee and mqtt interactions in case of active to stand-by switch over is triggered.
- __Automatic synchronization of Sonoff ZDonble-P coordinator Non-Volatile RAM__ from active to stand-by instance, in each zigbee2mqtt node where the dongle is connected to. It enables a seamless change of zigbee coordinator from active to stand-by node when required (avoiding impact on the rest of zigbee nodes, not requiring to re-join them to the network).
- __Control point enabled in a third node__ where MQTT broker is working, to detect issues with active zigbmee2mqtt instance and trigger the switch-over to change service to stanby-by node. The prototype includes the automated management of this control point in a Home Assistant instance with MQTT component configured

The overall design diagram is the following:

<img src="./zigbee2mqtt_ha_architecture.PNG" title="zigbee2mqtt HA architecture" width=800px></img>

## Test environment details

Find below some relevant details about the test environment used. In case of using a diferent environment, it could be required to make some minor adaptations in the scripts:

- __Zigbee coordinators (2x)__: Sonoff ZBDongle-P. In case of using a different one, it could involve to change the commands to read and write non volatile memory in the dongles.
- __Zigbee2mqtt nodes (2x)__: usage of up-to-date Alpine Linux distribution to execute zigbee2mqtt service. Zigbee2mqtt application is deployed and started and stopped using Alpine service commands defined for that purpose.
  - Example of Alpine service content of /etc/init.d/zigbee2mqtt to start and stop the application with rc-service command: https://github.com/chemadh/zigbee2mqtt_ha/blob/main/zigbee2mqtt_alpine_service_example
- __MQTT broker node__: Usage of Linux Debian distribution for High-Availability control script execution. Home assistant containing the MQTT broker component communicating with Zigbee2mqtt deployed in Docker mode in the same Linux node. Some referrence instructions:
  - Home Assistant supervised setup: https://community.home-assistant.io/t/installing-home-assistant-supervised-using-debian-12/200253
  - Installation of Mosquitto broker Home Assitant component:  https://www.home-assistant.io/integrations/mqtt

Common components used in the nodes previously defined:

- __Linux packages__: rsync, snmp (net-snmp-tools for Alpine; snmpd, snmp, libsnmp-dev, for Debian).
  - In addition to this, specifically for zigbee2mqtt nodes: python3, py3-pip. Instalation of zigpy-znp python component (pip install zigpy-znp). Aditional info in this link: https://github.com/zigpy/zigpy-znp/blob/0cacf7a51d205ac3a19acde10a8115cf5ac36ce1/TOOLS.md
- __SNMP MIBs__: The scripts notify about execution results using SNMP traps. The MIBs to be incluided in each linux node using the proposed scripts are stored in https://github.com/chemadh/zigbee2mqtt_ha/tree/main/MIBs 
- __Enable remote ssh connection__ between components without interactive credentials. Some example instructions here: https://www.thegeekdiary.com/how-to-run-scp-without-password-prompt-interruption-in-linux/

__Zigbee dongle configuration__:
- 
## Configuration files synchronization scripts
