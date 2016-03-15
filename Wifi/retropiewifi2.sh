#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wifi"
rp_module_desc="Configure Wifi"
rp_module_menus="3+"
rp_module_flags="nobin"


function wpa() {
    
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type Network Name" 22 76 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the network password" 22 76 $psk)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        psk="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tpsk="'$psk'"\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    
    printMsgs "dialog" "Configurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function wep() {
    
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type Network Name" 22 76 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter your WEP key" 22 76 $psk)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        psk="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tkey_mgmt=NONE\n\twep_tx_keyidx=0\n\tpsk='"$psk"'\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    
    printMsgs "dialog" "Configurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function open() {
    
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type Network Name" 22 76 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tkey_mgmt=NONE\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    
    printMsgs "dialog" "Configurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"

}


function configure_wifi() {

    local ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure Wifi.\nCurrent IP: $ip_int" 22 76 16)
        options=(
            1 "Connect to WPA/WPA2 Wifi Network. (Most Networks)"
            2 "Connect to WEP Wifi Network."
            3 "Connect to Open Wifi Network."
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    wpa
                    ;;
                2)
                    wep
                    ;;
                3)
                    open
                    ;;
            esac
        else
            break
        fi
    done
}
