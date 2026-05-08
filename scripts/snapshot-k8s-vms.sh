#!/bin/bash  
# snapshot-k8s-vms.sh  
# Snapshots de todas las VMs del cluster de kubernetes

set -e

#Chequeo la entrada de los argumentos
if [ "$#" -ne 2 ];  then 
	echo "Uso: $0 <argumento1> <argumento2>" 
	exit 1 
fi

#Capturo los argumentos y ejecuto las snapshots
NOMBRE_SNAPSHOT="${1}"  
DESCRIPCION="${2}"  
for i in 0 1 2 3; do  
echo "Creando snapshot '$SNAPSHOT_NAME' para la VM 22$i..."  
qm snapshot 22$i "$SNAPSHOT_NAME" --description "$DESCRIPTION"  
done  
echo "Todas las snapshots creadas correctamente"
