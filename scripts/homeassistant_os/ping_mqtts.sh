
#!/bin/bash

ssh -o UserKnownHostsFile=/config/.ssh/known_hosts -i /config/.ssh/id_rsa root@192.168.34.130 '/config/sh/remote/ping_mqtts.sh'

