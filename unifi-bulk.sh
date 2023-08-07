#!/bin/bash
#
# ============================================================="
# ============ UNIFI EDNS ENABLER ============================="
# ============ (c) 2023 suuhm ================================="
# ============================================================="
#
## ORIGIN CODE:
## https://the-suuhmmary.coldwareveryday.com/how-to-relay-client-ips-behind-upstream-dns-servers-with-edns
## https://www.commandlinux.com/man-page/man1/busybox.1.html
#
# Find Alias on root disk/ sho-t
# find / -type f -exec grep -H 'alias save' {} \;
# /usr/etc/profile:alias save='syswrapper.sh save-config'
#

#
# CONFIG SECTION
#
HOSTS="unifi_ap_hosts.lst"
UUN="ubnt"
# Plain Text Password
# USE WITH CAUTION!!!
PASSH_WRD="ubnt"
# echo "YOURPASSWORD" > /root/.unifi_ap.pass; chmod 600 /root/.unifi_ap.pass 
# PASSH_WRD="$(cat /root/.unifi_ap.pass)"
_IP_OF_EDGE_GATEWAY=192.168.1.1
_DNS_PORT=53

#
# END CONFIG SECTION
#

# GLOBAL CONF
_AUTOLOGIN=${2:-0}
OBFC=""
IDD=1D
_XC=0

# COMMANDLIST
_CMD_INFO='SYSF=/tmp/system.cfg;echo -e "[*] Version: $(cat /etc/version)\n[*] Checking for Forward Routermode (0x'"$IDD"'): $(cat /proc/sys/net/ipv4/ip_forward)"; info && sleep 2;grep -E "iptables.*cmd" $SYSF'
_CMD_SETHOST='SYSF=/tmp/system.cfg;clear;echo "[*] Checking for Forward Routermode: $(cat /proc/sys/net/ipv4/ip_forward)";sleep 2; echo ;sed -E -i "s+iptables.1.cmd=.*$+iptables.1.cmd=-t nat -A PREROUTING -p tcp -m mark --mark 0x40000000/0xc0000000 -j REDIRECT --to-ports 80; sleep 2; echo 1 > /proc/sys/net/ipv4/ip_forward+g" $SYSF; sed -E -i "s+iptables.2.cmd=.*$+iptables.2.cmd=-t nat -R PREROUTING 2 -p udp -m udp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination '"$_IP_OF_EDGE_GATEWAY"':'"$_DNS_PORT"'\niptables.3.cmd=-t nat -R PREROUTING 2 -p tcp -m tcp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination '"$_IP_OF_EDGE_GATEWAY"':'"$_DNS_PORT"'+g" $SYSF; echo;echo "Get IPTABLES" ;echo; iptables -t nat -S && echo && if [ `grep v4 /etc/version` ]; then echo "Old Version save.."; sleep 1; syswrapper.sh save-config; else echo "New Version save alias.."; save; fi && echo "[*] Done, now restart device"; sleep 2 && reboot'

#
# CUSTOM COMMAND LIST;
# PLEASE UNCOMMENT YOU WISHED COMMAND
#
# Some info test command
_CUSTOM_COMMAND='echo "Run Test command"; echo; sleep 1; uptime; echo; info'
#
# Run Firware Upgrade (Setup URL first)
#_CUSTOM_COMMAND='fwupdate --url https://<URL>.bin'
#
# Inform UNiFi server for new device
#_CUSTOM_COMMAND='set-inform http://'"$_IP_OF_EDGE_GATEWAY"':8080/inform'
#
# Set to system defaults and rebbot
#_CUSTOM_COMMAND='set-default && reboot'
#
# Set DNS Server
#_CUSTOM_COMMAND='echo "nameserver 9.9.9.9" > /etc/resolv.conf'
#

function _help() {
    echo -e "Usage: $0 [OPTION] [1] | = 1 For AUTOLOGINFUNCTION\n\n" \
             "\t--get-apinfo                                              Get some info of APs\n" \
             "\t--set-hosts                                               Setup APs for edns\n" \
             "\t--run-cmd 0|1 (AUTOLOGIN MUST BE SET!!) ['COMMANDS']      Run Custom cmmands on AP\n" \
             "\t--help                                                    Get help/ this view\n"
}


function obfuscate_cmd()
{
   CMD=${1:-$_CMD_INFO}
   # OBFUSCATE:
   OBFC=$(echo -n $CMD | base64)
}


function _run_cmd()
{
   if [ "$1" == "get-apinfo" ]; then
      obfuscate_cmd "$_CMD_INFO"
   elif [ "$1" == "set-hosts" ]; then
      obfuscate_cmd "$_CMD_SETHOST"
   else
      # TRY RUNNING CUSTOM COMMANDS:
      [ -z "$1" ] && echo "No Custom CMD was set, exit." && exit 1
      obfuscate_cmd "$1"
   fi
   echo "Using obfuscated base64 command.. no iterations yet.."
   echo -e "Command:\n$OBFC\r\n"; sleep 2

   for apnhostn in $(grep -v '#' $HOSTS); do
      apn=$(echo $apnhostn | cut -d ":" -f1)
      hostn=$(echo $apnhostn | cut -d ":" -f2)
      echo -e "\n\n-----------------------------------------------------------"
      echo -e " [+] Set up first Host $apn => IP: $hostn";
      echo -e "-----------------------------------------------------------"
      sleep 2; ((_XC++))

   #   ssh $UUN@$hostn 'SYSF=/tmp/system.cfg; \
   #   echo "[*] Checking for Forward Routermode: $(cat /proc/sys/net/ipv4/ip_forward)"; echo \
   #   sed -E -i "s+iptables.1.cmd=.*$+ \
   #   iptables.1.cmd=-t nat -A PREROUTING -p tcp -m mark --mark 0x40000000/0xc0000000 -j REDIRECT --to-ports 80; sleep 2; echo 1 > /proc/sys/net/ipv4/ip_forward+g" $SYSF \
   #   sed -E -i "s+iptables.2.cmd=.*$+ \
   #   iptables.2.cmd=-t nat -R PREROUTING 2 -p udp -m udp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination <IPOFEDGEGATEWAY>:53 \n \
   #   iptables.3.cmd=-t nat -R PREROUTING 2 -p tcp -m tcp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination <IPOFEDGEGATEWAY>:53+g" $SYSF  \
   #   echo; sleep 2 && echo && && [ `grep v4 /etc/version` ] && syswrapper.sh save-config || save ; sleep 2 ; reboot'

   #   ssh $UUN@$hostn 'SYSF=/tmp/system.cfg;clear;echo "[*] Checking for Forward Routermode: $(cat /proc/sys/net/ipv4/ip_forward)";sleep 2; echo ;sed -E -i "s+iptables.1.cmd=.*$+iptables.1.cmd=-t nat -A PREROUTING -p tcp -m mark --mark 0x40000000/0xc0000000 -j REDIRECT --to-ports 80; sleep 2; echo 1 > /proc/sys/net/ipv4/ip_forward+g" $SYSF; sed -E -i "s+iptables.2.cmd=.*$+iptables.2.cmd=-t nat -R PREROUTING 2 -p udp -m udp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination <IPOFEDGEGATEWAY>:53\niptables.3.cmd=-t nat -R PREROUTING 2 -p tcp -m udp --dport 53 -m mark --mark 0x40000000/0xc0000000 -j DNAT --to-destination <IPOFEDGEGATEWAY>:53+g" $SYSF; echo;echo "Get IPTABLES" ;echo; iptables -t nat -S && echo && syswrapper.sh save-config ; sleep 2 ; reboot'

      if [ $_AUTOLOGIN -eq 1 ]; then
         # FALLBACK: ash only or legacy bash methode:
         # echo $(echo -n $OBFC | base64 -di) | sshpass -p $PASSH_WRD ssh -T -o StrictHostKeyChecking=no $UUN@$hostn 'sh -s'
         sshpass -p $PASSH_WRD ssh -T -q -o StrictHostKeyChecking=no $UUN@$hostn <<<$(echo -n $OBFC | base64 -di) 2>/dev/null | egrep -v "^\ |^\*|^\t|^\r"
      else
         # echo $(echo -n $OBFC | base64 -di) | ssh -o StrictHostKeyChecking=no $UUN@$hostn 'sh -s'
         ssh -T -q -o StrictHostKeyChecking=no $UUN@$hostn <<<$(echo -n $OBFC | base64 -di) 2>/dev/null | egrep -v "^\ |^\*|^\t"
      fi
   done
}

#
## FUNCTION MAIN()
#
clear
echo
echo "  _____  __      ___________________    _____________  _____________ __"
echo "  __  / / /_________(_)__  ____/__(_)   ___  __ )_  / / /__  /___  //_/"
echo "  _  / / /__  __ \_  /__  /_   __  /    __  __  |  / / /__  / __  ,<   "
echo "  / /_/ / _  / / /  / _  __/   _  /     _  /_/ // /_/ / _  /___  /| |  "
echo "  \____/  /_/ /_//_/  /_/      /_/      /_____/ \____/  /_____/_/ |_|  "
echo "                                                                       "
echo
echo "======================================================================="
echo "========= UNIFI BULK PROCESSOR & EDNS ENABLER (c) 2023 suuhm =========="
echo "======================================================================="
echo; sleep 1

if [ "$1" == "--get-apinfo" ]; then
    _run_cmd "get-apinfo"
elif [ "$1" == "--set-hosts" ]; then
    _run_cmd "set-hosts"
# CMD LINE $0 --run-cmd <0|1> <- MUST BE SET! [COMMANDS] !!
elif [ "$1" == "--run-cmd" ]; then
    [ "$3" == "-" ] && _run_cmd "$_CUSTOM_COMMAND" \
                    || _run_cmd "$3"
else
    _help
    exit 1
fi

echo -e "\a\n-----------------------------\n[*] Scanned Hosts ($_XC) Done.\n"
exit 0;
