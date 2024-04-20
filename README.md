# Zigbee2mqtt High-Avaliability controller prototype

## Introduction

High Availability controller prototype for two zigbee2mqtt instances with independent USB zigbee dongles (specifically implemented for Sonoff ZBDongle-P). The final purpose is enabling that one of the zigbee2mqtt could play the "active" role, meanwhile the second is in "stand-by" status for a single zigbee network (enabling also an automated switch over to stand-by node in case of detecting problems in the active instance). Please note that zigbee standard only allows to define a single coordinator node, so the only available high-availability model to use is active-stand by. Detailed features:

- Automatic synchronization of zigbe2mqtt configuration and data files from active to stand-by instance, to ensure an up-to-date zigbee and mqtt interactions in case of active to stand-by switch over is triggered.
- Automatic synchronization of Sonoff ZDonble-P coordinator Non-Volatile RAM from active to stand-by instance, in each zigbee2mqtt node where the dongle is connected to. It enables a seamless change of zigbee coordinator from active to stand-by node when required (avoiding impact on the rest of zigbee nodes, not requiring to re-join them to the network).
- Control point enabled in a third node where MQTT broker is working, to detect issues with active zigbmee2mqtt instance and trigger the switch-over to change service to stanby-by node. The prototype includes the automated management of this control point in a Home Assistant instance with MQTT component configured

The overall design diagram is the following:

<img src="./zigbee2mqtt_ha_architecture.PNG" title="zigbee2mqtt HA architecture" width=800px></img>

## Test environment details

Find below some relevant details about the test environment used. In case of using a diferent environment, it could be required to make some minor adaptations in the scripts:

- Zigbee coordinator: Sonoff ZBDongle-P. In case of using a different one, it could involve to change the commands to read and write non volatile memory in the dongles.
- Zigbee2mqtt node: usage of up-to-date Alpine Linux distribution to execute zigbee2mqtt service. Zigbee2mqtt application is started and stopped using Alpine service commands defined for that purpose.
- MQTT broker node: 

## Configuration files synchronization scripts
