List Wifi Networks: iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//'

Save New /etc/network/interfaces:
echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet dhcp\n\twpa-ssid "'$wifiSSID'"\n\twpa-psk "'$wifiPassword'"' > "/etc/network/interfaces"


How it should work:

-list wifi and create a radio list from results. choose your ssid.

- (Potential option here to choose wpa or WEP)

-Type password for selected SSID

#Taken from Here: https://www.raspberrypi.org/forums/viewtopic.php?t=7592

-if Static IP then

iface wlan0 inet static
address UR_IP
gateway UR_ROUTER_IP
netmask 255.255.255.0

-If WPA then:

 WPA:
 wpa-ssid "Your Wireless Network Name"
 wpa-psk "Your Wireless Network Password"
 
-If WEP then:
 
 WEP
 wireless-essid NETWORK_NAME
 wireless-key NETWORK_PASSWORD

-If Open Wireless then:
 
 wireless-essid UR_ESSID
 wireless-mode managed

-if Hidden SSID?

wpa-driver wext
wpa-ssid UR_ESSID
#; wpa-ap-scan is 1 for visible and 2 for hidden hubs
wpa-ap-scan 2
#; wpa-proto is WPA for WPA1 (aka WPA) or RSN for WPA2
wpa-proto WPA 
#; wpa-pairwise and wpa-group is TKIP for WPA1 or CCMP for WPA2
wpa-pairwise TKIP
wpa-group TKIP
wpa-key-mgmt WPA-PSK
#; use "wpa_passphrase UR_ESSID UR_KEY" to generate UR_HEX_KEY
#; enter the result below
wpa-psk UR_HEX_KEY


-Have it update and save a new interfaces file.

Alternate Ideas/ Enhancements:

-static IPs: done

-Option for WEP: done

-Option for Open Network: done

-Option for hidden SSID: done

-Option for Backups?: done

-Wpa Supplicant instead of Interfaces for multiple networks?

-Catch to automagically reconnect if network goes down.

-Simplify code logic, as to enable security type, hidden ssids, and static IP's in one option instead of 7 individual options and in the future hopefully appends into wpa_supplicant instead of interfaces.
