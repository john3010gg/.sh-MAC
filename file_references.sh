#!/bin/bash

FILE="$HOME/references.txt"

if [ ! -f "$FILE" ]; then
	touch "$FILE"
fi

COMMAND=$1

if [ -z "$COMMAND" ]; then
 	echo "Cómo usar este script:"
 	echo "./file_references.sh list"
    	echo "./file_references.sh add nombre ruta"
    	echo "./file_references.sh delete nombre"
    	echo "./file_references.sh chmod nombre permisos"
    	exit 1
fi


if [ "$COMMAND" = "list" ]; then
   	if [ ! -s "$FILE" ]; then
        	echo "No hay nada guardado."
    	else
        	echo "Lista de referencias:"
        	cat "$FILE"
   	 fi
   	 exit 0
fi


if [ "$COMMAND" = "add" ]; then
	NAME=$2
  	PATH=$3
    	if [ -z "$NAME" ]; then
        	echo "Falta el nombre. Usa: ./file_references.sh add nombre ruta"
        	exit 1
    	fi
    	if [ -z "$PATH" ]; then
        	echo "Falta la ruta. Usa: ./file_references.sh add nombre ruta"
        	exit 1
    	fi

   
   	 if [ ! -e "$PATH" ]; then
        	echo "Error: $PATH no existe."
        	exit 1
    	fi

   	 if [ -b "$PATH" ]; then
        	echo "Error: $PATH es un dispositivo, no se puede agregar."
        	exit 1
    	fi
    	if [ -c "$PATH" ]; then
        	echo "Error: $PATH es un dispositivo, no se puede agregar."
        	exit 1
    	fi

  
    	if cat "$FILE" | grep "$NAME|" > /dev/null; then
        	echo "Error: El nombre $NAME ya está usado."
        	exit 1
    	fi

    
    	echo "$NAME|$PATH" >> "$FILE"
    	echo "Agregado: $NAME -> $PATH"
    	exit 0
fi


if [ "$COMMAND" = "delete" ]; then
	NAME=$2
    
    	if [ -z "$NAME" ]; then
        	echo "Falta el nombre. Usa: ./file_references.sh delete nombre"
        	exit 1
    	fi

    	if ! cat "$FILE" | grep "$NAME|" > /dev/null; then
        	echo "Error: El nombre $NAME no existe."
        	exit 1
    	fi

   	echo "" > temp.txt
    	while read LINE; do
        	if ! echo "$LINE" | grep "$NAME|" > /dev/null; then
            		echo "$LINE" >> temp.txt
        	fi
    	done < "$FILE"
    	mv temp.txt "$FILE"
    	echo "Eliminado: $NAME"
    	exit 0
fi

if [ "$COMMAND" = "chmod" ]; then
    	NAME=$2
    	PERMS=$3
    	if [ -z "$NAME" ]; then
        	echo "Falta el nombre. Usa: ./file_references.sh chmod nombre permisos"
        	exit 1
    	fi
    	if [ -z "$PERMS" ]; then
        	echo "Falta los permisos. Usa: ./file_references.sh chmod nombre permisos"
        	exit 1
    	fi

	FOUND=0
	PATH=""
   	while read LINE; do
        	if echo "$LINE" | grep "$NAME|" > /dev/null; then
            		FOUND=1
            		PATH=""
            		START=0
            		for CHAR in $(echo "$LINE" | fold -w1); do
                		if [ "$CHAR" = "|" ]; then
                    			START=1
                    			continue
                		fi
                		if [ $START -eq 1 ]; then
                    			PATH="$PATH$CHAR"
                		fi
            		done
            		break
        	fi
    	done < "$FILE"

	if [ $FOUND -eq 0 ]; then
       		echo "Error: El nombre $NAME no existe."
        	exit 1
    	fi

	if [ ! -e "$PATH" ]; then
        	echo "Error: El archivo $PATH no existe."
        	exit 1
    	fi

    	if chmod "$PERMS" "$PATH"; then
        	echo "Permisos cambiados: $PATH ahora tiene $PERMS"
    	else
        	echo "Error al cambiar permisos de $PATH"
        	exit 1
    	fi
    	exit 0
fi

echo "Comando no válido. Usa:"
echo "./file_references.sh list"
echo "./file_references.sh add nombre ruta"
echo "./file_references.sh delete nombre"
echo "./file_references.sh chmod nombre permisos"
exit 1
