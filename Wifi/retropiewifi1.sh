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


function ssid() {
    
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type Network Name" 22 76 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi
}

function psk() {
    
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the network password" 22 76 $psk)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        psk="$choice"
    fi
}

function wifi_saveconfig() {

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tpsk="'$psk'"\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    
    printMsgs "dialog" "Configuration has been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function configure_wifi() {

    local ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure Wifi.\nCurrent IP: $ip_int" 22 76 16)
        options=(
            1 "Choose Network SSID. Currently: $ssid"
            2 "Choose Network Password Currently: $psk"
            3 "Save configuration"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    ssid
                    ;;
                2)
                    psk
                    ;;
                3)
                    wifi_saveconfig
                    ;;
            esac
        else
            break
        fi
    done
}
