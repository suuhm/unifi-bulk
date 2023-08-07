# unifi-bulk
Easy to use shell script for mass editing your UniFi devices

```

  _____  __      ___________________    _____________  _____________ __
  __  / / /_________(_)__  ____/__(_)   ___  __ )_  / / /__  /___  //_/
  _  / / /__  __ \_  /__  /_   __  /    __  __  |  / / /__  / __  ,<
  / /_/ / _  / / /  / _  __/   _  /     _  /_/ // /_/ / _  /___  /| |
  \____/  /_/ /_//_/  /_/      /_/      /_____/ \____/  /_____/_/ |_|


=======================================================================
========= UNIFI BULK PROCESSOR & EDNS ENABLER (c) 2023 suuhm ==========
=======================================================================

```

Originally, this script was only planned as EDNS helper-script (here is a link to the blog: https://the-suuhmmary.coldwareveryday.com/how-to-relay-client-ips-behind-upstream-dns-servers-with-edns/). 
But now it became a relatively useful tool to upgrade and modify as many unifi devices as possible at the same time.
Without the unifi control suite mind you and completely natively tunneled over ssh

## How to use

1. Clone the script via
```bash
git clone https://github.com/suuhm/unifi-bulk.git && cd unifi-bulk
chmod +x unifi-bulk.sh
```

2. Edit and or add your wished hosts to the `unifi_ap_hosts.lst` file
```lst
#
# HOSTNAME : IP LIST:
# Don't use ':' in your name 
# cause of delimititers
#
UNIFI_AP_1:10.1.2.3.4
...
UNIFI_AP_1:10.1.2.3.26
UNIFI_AP_1:10.1.2.3.17
```

3. Edit the `unifi-bulk.sh` file:
```bash
#
# CONFIG SECTION
#
HOSTS="unifi_ap_hosts.lst"
UUN="ubnt"
# Plain Text Password
# USE WITH CAUTION!!!
PASSH_WRD="ubnt"
_IP_OF_EDGE_GATEWAY=192.168.1.1
_DNS_PORT=53
```

### Important! Don't use plain text passwords!
Use this method here for example root:

```bash
echo "YOURPASSWORD" > /root/.unifi_ap.pass; chmod 600 /root/.unifi_ap.pass
# Edit the `unifi-bulk.sh` file:
PASSH_WRD="$(cat /root/.unifi_ap.pass)"
```

4. Run Script:
```bash

  _____  __      ___________________    _____________  _____________ __
  __  / / /_________(_)__  ____/__(_)   ___  __ )_  / / /__  /___  //_/
  _  / / /__  __ \_  /__  /_   __  /    __  __  |  / / /__  / __  ,<
  / /_/ / _  / / /  / _  __/   _  /     _  /_/ // /_/ / _  /___  /| |
  \____/  /_/ /_//_/  /_/      /_/      /_____/ \____/  /_____/_/ |_|


=======================================================================
========= UNIFI BULK PROCESSOR & EDNS ENABLER (c) 2023 suuhm ==========
=======================================================================

Usage: ./unifi-bulk.sh [OPTION] <0|1> | = 1 For AUTOLOGINFUNCTION

        --get-apinfo                                              Get some info of APs
        --set-hosts                                               Setup APs for edns
        --run-cmd 0|1 (AUTOLOGIN MUST BE SET!!) ['COMMANDS']|-    Run Custom cmmands on AP
        --help                                                    Get help/ this view
```

## Examples

Get info with autologin of all AP's

```bash
./unifi-bulk.sh --get-apinfo 1
```

Set EDNS without autologin of all AP's

```bash
./unifi-bulk.sh --set-hosts 0
```

Run own commands with autologin of all AP's

```bash
./unifi-bulk.sh --run-cmd 1 'pwd && iptables -L; cat /tmp/system.cfg; info; echo "Using a String with echo"; sleep 1'
```

Run own hardcoded command (in head of script file) without autologin of all AP's

```bash
./unifi-bulk.sh --run-cmd 0 -
```


## All rights reserved 2023 (c) suuhm

## Let me know if you find some bugs and feature wishes and post an issue!
