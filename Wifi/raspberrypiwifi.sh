#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  whiptail --title "$1" \
    --clear \
    --msgbox "$result" 0 0
}

#########
#Shows the network menu options
#########
	stayInNetworkMenu=true
	while $stayInNetworkMenu; do
		exec 3>&1
		NetworkMenuSelection=$(whiptail \
			--title "Network Configuration" \
			--clear \
			--cancel-button "Exit" \
			--menu "Please select:" $HEIGHT $WIDTH 3 \
			"1" "Display Network Information" \
			"2" "Scan for WiFI Networks (Root Required)" \
			"3" "Connect to WPA WiFi Network (Root Required)" \
			"4" "Connect to WEP WiFi Network (Root Required)" \
			"5" "Connect to Open WiFi Network (Root Required)" \
			"6" "Connect to Hidden WPA SSID Network (Root Required)" \
			"7" "Connect to WPA SSID Network with Static IP (Root Required)" \
			2>&1 1>&3)
		exit_status=$?
		case $exit_status in
			$DIALOG_CANCEL)
			  clear
        		  #echo "Program terminated."
      			  exit
     			  ;;
			$DIALOG_ESC)
			  clear
      			  #echo "Program aborted." >&2
      			  exit 1
      			  ;;
		esac
		case $NetworkMenuSelection in
			0 )
			  stayInNetworkMenu=false
			  ;;
			1 )
				result=$(ifconfig)
				display_result "Network Information"
				;;
			2 )
				currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					result=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					display_result "WiFi Networks"
				else
					result=$(echo "You have to be running the script as root in order to scan for WiFi networks. Please try using sudo.")
					display_result "WiFi Network"
				fi
				;;
			3 )
				currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					wifiNetworkList=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					wifiSSID=$(whiptail --title "WiFi Network SSID" --inputbox "Network List: \n\n$wifiNetworkList \n\nEnter the SSID of the WiFi network you would like to connect to:" 0 0 2>&1 1>&3);
					if [ "$wifiSSID" != "" ] ; then
						actuallyConnectToWifi=false
						networkInterfacesConfigLocation="/etc/network/interfaces"
						
						if (whiptail --title "Create Backup?" --yesno "Would you like to create a backup of your current network interfaces config?" 0 0) then
							if [ ! -f $networkInterfacesConfigLocation"_bak" ] ; then
								cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
							else
								if (whiptail --title "Overwrite Backup?" --yesno "A backup currently exists. Do you want to overwrite it?" 0 0) then
									cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
								fi
								actuallyConnectToWifi=true
							fi		
						else
							actuallyConnectToWifi=true
						fi
						if [ $actuallyConnectToWifi == true ] ; then
							wifiPassword=$(whiptail --title "WiFi Network Password" --passwordbox "Enter the password of the WiFi network you would like to connect to:" 10 70 2>&1 1>&3);
							if [ ! "$wifiPassword" == "" ] ; then
								echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet dhcp\n\twpa-ssid "'$wifiSSID'"\n\twpa-psk "'$wifiPassword'"' > $networkInterfacesConfigLocation
								ifdown wlan0 > /dev/null 2>&1
								ifup wlan0 > /dev/null 2>&1
								
								inetAddress=$(ifconfig wlan0 | grep "inet addr.*")
								if [ "$inetAddress" != "" ] ; then
									result=$(echo "You are now connected to $wifiSSID.")
									display_result "WiFi Network"
								else
									result=$(echo "There was an issue trying to connect to $wifiSSID. Please ensure you typed the SSID and password correctly.")
									display_result "WiFi Network"
								fi
							fi
						fi
					fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
			4 )
			currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					wifiNetworkList=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					wifiSSID=$(whiptail --title "WiFi Network SSID" --inputbox "Network List: \n\n$wifiNetworkList \n\nEnter the SSID of the WiFi network you would like to connect to:" 0 0 2>&1 1>&3);
					if [ "$wifiSSID" != "" ] ; then
						actuallyConnectToWifi=false
						networkInterfacesConfigLocation="/etc/network/interfaces"
						
						if (whiptail --title "Create Backup?" --yesno "Would you like to create a backup of your current network interfaces config?" 0 0) then
							if [ ! -f $networkInterfacesConfigLocation"_bak" ] ; then
								cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
							else
								if (whiptail --title "Overwrite Backup?" --yesno "A backup currently exists. Do you want to overwrite it?" 0 0) then
									cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
								fi
								actuallyConnectToWifi=true
							fi		
						else
							actuallyConnectToWifi=true
						fi
						if [ $actuallyConnectToWifi == true ] ; then
							wifiPassword=$(whiptail --title "WiFi Network Password" --passwordbox "Enter the password of the WiFi network you would like to connect to:" 10 70 2>&1 1>&3);
							if [ ! "$wifiPassword" == "" ] ; then
								echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet dhcp\n\twireless-essid '"$wifiSSID"'\n\twireless-key '"$wifiPassword"'' > $networkInterfacesConfigLocation
								ifdown wlan0 > /dev/null 2>&1
								ifup wlan0 > /dev/null 2>&1
								
								inetAddress=$(ifconfig wlan0 | grep "inet addr.*")
								if [ "$inetAddress" != "" ] ; then
									result=$(echo "You are now connected to $wifiSSID.")
									display_result "WiFi Network"
								else
									result=$(echo "There was an issue trying to connect to $wifiSSID. Please ensure you typed the SSID and password correctly.")
									display_result "WiFi Network"
								fi
							fi
						fi
					fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
			5 )
			currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					wifiNetworkList=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					wifiSSID=$(whiptail --title "WiFi Network SSID" --inputbox "Network List: \n\n$wifiNetworkList \n\nEnter the SSID of the WiFi network you would like to connect to:" 0 0 2>&1 1>&3);
					if [ "$wifiSSID" != "" ] ; then
						actuallyConnectToWifi=false
						networkInterfacesConfigLocation="/etc/network/interfaces"
						
						if (whiptail --title "Create Backup?" --yesno "Would you like to create a backup of your current network interfaces config?" 0 0) then
							if [ ! -f $networkInterfacesConfigLocation"_bak" ] ; then
								cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
							else
								if (whiptail --title "Overwrite Backup?" --yesno "A backup currently exists. Do you want to overwrite it?" 0 0) then
									cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
								fi
								actuallyConnectToWifi=true
							fi		
						else
							actuallyConnectToWifi=true
						fi
						if [ $actuallyConnectToWifi == true ] ; then
								echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet dhcp\n\twireless-essid '"$wifiSSID"'\n\twireless-mode managed' > $networkInterfacesConfigLocation
								ifdown wlan0 > /dev/null 2>&1
								ifup wlan0 > /dev/null 2>&1
								
								inetAddress=$(ifconfig wlan0 | grep "inet addr.*")
								if [ "$inetAddress" != "" ] ; then
									result=$(echo "You are now connected to $wifiSSID.")
									display_result "WiFi Network"
								else
									result=$(echo "There was an issue trying to connect to $wifiSSID. Please ensure you typed the SSID and password correctly.")
									display_result "WiFi Network"
								fi
							fi
						fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
			6 )
			currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					wifiSSID=$(whiptail --title "WiFi Network SSID" --inputbox "Network List: Enter the Hidden SSID of the WiFi network you would like to connect to:" 0 0 2>&1 1>&3);
					if [ "$wifiSSID" != "" ] ; then
						actuallyConnectToWifi=false
						networkInterfacesConfigLocation="/etc/network/interfaces"
						
						if (whiptail --title "Create Backup?" --yesno "Would you like to create a backup of your current network interfaces config?" 0 0) then
							if [ ! -f $networkInterfacesConfigLocation"_bak" ] ; then
								cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
							else
								if (whiptail --title "Overwrite Backup?" --yesno "A backup currently exists. Do you want to overwrite it?" 0 0) then
									cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
								fi
								actuallyConnectToWifi=true
							fi		
						else
							actuallyConnectToWifi=true
						fi
						if [ $actuallyConnectToWifi == true ] ; then
							wifiPassword=$(whiptail --title "WiFi Network Password" --passwordbox "Enter the password of the WiFi network you would like to connect to:" 10 70 2>&1 1>&3);
							if [ ! "$wifiPassword" == "" ] ; then
							hexkey=$( wpa_passphrase "$wifiSSID" "$wifiPassword" | grep psk | awk '{if(NR==2)print $0}' | sed 's/^.\{5\}//g')
								echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet dhcp\nwpa-driver wext\n\twpa-ssid "'$wifiSSID'"\nwpa-ap-scan 2\nwpa-proto WPA\nwpa-pairwise TKIP\nwpa-group TKIP\nwpa-key-mgmt WPA-PSK\n\twpa-psk "'$hexkey'"' > $networkInterfacesConfigLocation
								ifdown wlan0 > /dev/null 2>&1
								ifup wlan0 > /dev/null 2>&1
								
								inetAddress=$(ifconfig wlan0 | grep "inet addr.*")
								if [ "$inetAddress" != "" ] ; then
									result=$(echo "You are now connected to $wifiSSID.")
									display_result "WiFi Network"
								else
									result=$(echo "There was an issue trying to connect to $wifiSSID. Please ensure you typed the SSID and password correctly.")
									display_result "WiFi Network"
								fi
							fi
						fi
					fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
			7 )
				currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					ifconfig wlan0 up
					wifiNetworkList=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					wifiSSID=$(whiptail --title "WiFi Network SSID" --inputbox "Network List: \n\n$wifiNetworkList \n\nEnter the SSID of the WiFi network you would like to connect to:" 0 0 2>&1 1>&3);
					if [ "$wifiSSID" != "" ] ; then
						actuallyConnectToWifi=false
						networkInterfacesConfigLocation="/etc/network/interfaces"
						
						if (whiptail --title "Create Backup?" --yesno "Would you like to create a backup of your current network interfaces config?" 0 0) then
							if [ ! -f $networkInterfacesConfigLocation"_bak" ] ; then
								cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
							else
								if (whiptail --title "Overwrite Backup?" --yesno "A backup currently exists. Do you want to overwrite it?" 0 0) then
									cp $networkInterfacesConfigLocation $networkInterfacesConfigLocation"_bak"
								fi
								actuallyConnectToWifi=true
							fi		
						else
							actuallyConnectToWifi=true
						fi
						if [ $actuallyConnectToWifi == true ] ; then
							wifiPassword=$(whiptail --title "WiFi Network Password" --passwordbox "Enter the password of the WiFi network you would like to connect to:" 10 70 2>&1 1>&3);
							if [ ! "$wifiPassword" == "" ] ; then
							ip=$(whiptail --title "New Raspberry Pi IP" --inputbox "\n\nEnter the IP address you would like your Raspberry Pi to have e.g. 192.168.0.110:" 0 0 2>&1 1>&3); 
							if [ "$ip" != "" ] ; then
							gatewaylist=$(netstat -nr)
							gateway=$(whiptail --title "Gateway" --inputbox "Gateway List: \n\n$gatewaylist \n\nEnter the default gateway for your router: typically 192.168.0.1:" 0 0 2>&1 1>&3);
							if [ ! "$gateway" == "" ] ; then
							netmask=$(whiptail --title "Netmask" --inputbox "\n\nEnter the default netmask for your router: typically 255.255.255.0:" 0 0 2>&1 1>&3);
							if [ ! "$netmask" == "" ] ; then
							echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet static\n\taddress "'$ip'"\n\tgateway "'$gateway'"\n\tnetmask "'$netmask'"\n\twpa-ssid "'$wifiSSID'"\n\twpa-psk "'$wifiPassword'"' > $networkInterfacesConfigLocation
								ifdown wlan0 > /dev/null 2>&1
								ifup wlan0 > /dev/null 2>&1
								
								inetAddress=$(ifconfig wlan0 | grep "inet addr.*")
								if [ "$inetAddress" != "" ] ; then
									result=$(echo "You are now connected to $wifiSSID.")
									display_result "WiFi Network"
								else
									result=$(echo "There was an issue trying to connect to $wifiSSID. Please ensure you typed the SSID and password correctly.")
									display_result "WiFi Network"
								fi
								fi
								fi
								fi
							fi
						fi
					fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
		esac
	done
