#!/bin/bash

LOG_FILE="usb_log.txt"
[ ! -f "$LOG_FILE" ] && echo "Registro de eventos USB" > "$LOG_FILE"

echo "Viendo USB... CTRL+C para acabar:0"
known_devices=""

while true; do
    current_devices=$(lsusb | awk '{print $2, $4, $6}' | sed 's/://g')

    new_devices=""
    while read -r dev_info; do
        if ! echo "$known_devices" | grep -q "$dev_info"; then
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$timestamp] Conexión: $dev_info" >> "$LOG_FILE"
        fi
        new_devices="$new_devices"$'\n'"$dev_info"
    done <<< "$current_devices"

    while read -r dev_info; do
        if ! echo "$current_devices" | grep -q "$dev_info"; then
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$timestamp] Desconexión: $dev_info" >> "$LOG_FILE"
        fi
    done <<< "$known_devices"

    known_devices="$current_devices"
    sleep 1
done

