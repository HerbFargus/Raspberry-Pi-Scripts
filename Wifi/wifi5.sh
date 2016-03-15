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


function list_wifi() { 
	local line 
	local essid 
	local type 
	while read line; do 
		[[ "$line" =~ ^Cell && -n "$essid" ]] && echo -e "$essid\n$type" 
		[[ "$line" =~ ^ESSID ]] && essid=$(echo "$line" | cut -d\" -f2) 
		[[ "$line" == "Encryption key:off" ]] && type="open" 
		[[ "$line" == "Encryption key:on" ]] && type="wep" 
		[[ "$line" =~ ^IE:.*WPA ]] && type="wpa" 
	done < <(iwlist wlan0 scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*") 
	echo -e "$essid\n$type" 
} 


	stayInNetworkMenu=true
	while $stayInNetworkMenu; do
		exec 3>&1
		networkMenuSeleciton=$(whiptail \
			--title "System Information" \
			--clear \
			--cancel-button "Back" \
			--menu "Please select:" $HEIGHT $WIDTH 3 \
			"1" "Display Network Information" \
			"2" "Scan for WiFI Networks (Root Required)" \
			"3" "Connect to WiFi Network (Root Required)" \
			2>&1 1>&3)
		exit_status=$?
		case $exit_status in
			$DIALOG_CANCEL)
			  stayInNetworkMenu=false
			  ;;
			$DIALOG_ESC)
			  stayInNetworkMenu=false
			  ;;
		esac
		case $networkMenuSeleciton in
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
					#result=$(iwlist wlan0 scan | grep ESSID | sed 's/ESSID://g;s/"//g;s/^ *//;s/ *$//')
					result=$(iwlist wlan0 scan | grep ESSID | awk -F \" '{print $2}')
					display_result "WiFi Networks"
				else
					result=$(echo "You have to be running the script as root in order to scan for WiFi networks. Please try using sudo.")
					display_result "WiFi Network"
				fi
				;;
			3 )
				currentUser=$(whoami)
				if [ $currentUser == "root" ] ; then
					local line
					local essid
					local type
					while read line; do
						[[ "$line" =~ ^Cell && -n "$essid" ]] #&& echo -e "$essid\n$type"
						[[ "$line" =~ ^ESSID ]] && essid=$(echo "$line" | cut -d\" -f2)
						[[ "$line" == "Encryption key:off" ]] && type="open"
						[[ "$line" == "Encryption key:on" ]] && type="wep"
						[[ "$line" =~ ^IE:.*WPA ]] && type="wpa"
					done < <(iwlist wlan0 scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*")
					
					local essids=() 
					local types=() 
					local options=()
					i=0 
					while read essid; read type; do 
						essids+=("$essid") 
						types+=("$type") 
						options+=("$i" "$essid") 
						((i++)) 
					done < <(list_wifi)
					options+=("H" "Hidden ESSID")
					
					local cmd=(whiptail --menu "Please choose the network you would like to connect to" 22 76 16) 
					choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
					[[ -z "$choice" ]] && return 
 
					local hidden=0 
					if [[ "$choice" == "H" ]]; then 
						cmd=(whiptail --inputbox "Please enter the ESSID" 10 60) 
						essid=$("${cmd[@]}" 2>&1 >/dev/tty) 
						[[ -z "$essid" ]] && return 
						cmd=(whiptail --nocancel --menu "Please choose the WiFi type" 12 40 6) 
						options=( 
							wpa "WPA/WPA2" 
							wep "WEP" 
							open "Open" 
						) 
						type=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
						hidden=1 
					else 
						essid=${essids[choice]} 
						type=${types[choice]} 
					fi

					if [[ "$type" == "wpa" || "$type" == "wep" ]]; then 
						local key="" 
						cmd=(whiptail --title "WiFi Network Password" --passwordbox "Please enter the WiFi key/password for $essid" 10 63) 
						local key_ok=0 
						while [[ $key_ok -eq 0 ]]; do 
							key=$("${cmd[@]}" 2>&1 >/dev/tty) 
							key_ok=1 
							if [[ ${#key} -lt 8 || ${#key} -gt 63 ]] && [[ "$type" == "wpa" ]]; then
								result=$("Password must be between 8 and 63 characters")
								display_result "Network Information"
								key_ok=0 
							fi 
							if [[ -z "$key" && $type == "wep" ]]; then
								result=$("Password cannot be empty")
								display_result "Network Information"
								key_ok=0 
							fi 
						done 
					fi
					
					local wpa_config 
					wpa_config+="\tssid=\"$essid\"\n" 
					case $type in 
						wpa) 
							wpa_config+="\tpsk=\"$key\"\n" 
							;; 
						wep) 
							wpa_config+="\tkey_mgmt=NONE\n" 
							wpa_config+="\twep_tx_keyidx=0\n" 
							wpa_config+="\twep_key0=$key\n" 
							;; 
						open) 
							wpa_config+="\tkey_mgmt=NONE\n" 
						;; 
					esac 
     
					[[ $hidden -eq 1 ]] &&  wpa_config+="\tscan_ssid=1\n"
					
					#if wifi ssid already exists in the wpa_supplicant.conf alert the user and don't continue
					#this will be replaced by removing that specific configuration in the future
					if grep -q "$essid" "$wpaSupplicantLocation"; then
						result=$(echo "The wifi ssid is already in the wpa_supplicant file. You will have to manually delete it from the /etc/wpa_supplicant/wpa_supplicant.conf file if you want to update the WiFi connection information. This will be automated in the future.")
						display_result "WiFi Network"
					else
						echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\niface default inet dhcp' > $networkInterfacesConfigLocation
						echo -e '\nnetwork={\n'"$wpa_config"'}\n' >> $wpaSupplicantLocation
						
						ifup wlan0 &>/dev/null 
						local id="" 
						i=0 
						while [[ -z "$id" && $i -lt 20 ]]; do 
							sleep 1 
							id=$(iwgetid -r) 
							((i++)) 
						done
						
						result=$(echo "Unable to connect to network $essid. If you have a ethernet cord currently plugged in, the WiFi will not be utilized until that is unplugged. This could be the reason for not being able to connect to the wifi network.")
						[[ -z "$id" ]] && display_result "Network Information"
					fi
				else
					result=$(echo "You have to be running the script as root in order to connect to a WiFi network. Please try using sudo.")
					display_result "WiFi Network"
				fi
			;;
		esac
	done
