#!/bin/bash

# Verifica si se proporcionó un nombre de módulo
if [ -z "$1" ]; then
    echo "Error: Debe proporcionar el nombre del módulo"
    exit 1
fi

MODULE="$1"

# Verifica si el módulo está cargado
if lsmod | grep -q "^${MODULE}\b"; then
    echo "El módulo $MODULE está activado."
    read -p "¿Desea desactivarlo? (s/n): " choice
    if [ "$choice" = "s" ]; then
        if sudo rmmod "$MODULE"; then
            echo "Módulo $MODULE desactivado exitosamente."
        else
            echo "Error al desactivar el módulo $MODULE."
            exit 1
        fi
    fi
else
    echo "El módulo $MODULE no está activado."
    read -p "¿Desea activarlo? (s/n): " choice
    if [ "$choice" = "s" ]; then
        if sudo modprobe "$MODULE"; then
            echo "Módulo $MODULE activado exitosamente."
        else
            echo "Error al activar el módulo $MODULE."
            exit 1
        fi
    fi
fi
