#!/bin/bash
# create-k8s-vms.sh
# Crea las VMs para el cluster de kubernetes
# Este script se lanza desde el host proxmox (192.168.1.210)

set -e

# Defino las variables comunes
TEMPLATE_ID=1000
SSH_KEY="ssh-ed25519 XXXX <-- Tu clave"
GATEWAY="192.168.1.1"
NAMESERVER="192.168.1.1"
SEARCH_DOMAIN="localdomain"

# Creo una función de como se ejecutarán los comandos
create_vm() {
    local vmid=$1 name=$2 ip=$3 memory=$4 cores=$5 disk=$6
    echo "Creando la VM $vmid: $name..."
    qm clone $TEMPLATE_ID $vmid --name $name --full
    qm set $vmid --memory $memory --cores $cores
    qm resize $vmid scsi0 "${disk}G"
    qm set $vmid --ipconfig0 "ip=${ip}/24,gw=$GATEWAY"
    qm set $vmid --nameserver $NAMESERVER 
    qm set $vmid --searchdomain $SEARCH_DOMAIN
    qm set $vmid --sshkeys <(echo "$SSH_KEY")
    echo "VM $vmid creada"
}

# Lanzo los comandos anteriores pasandole las variables para cada VM
create_vm 220 "k8s-master"     "192.168.1.220" 4096 2 50
create_vm 221 "k8s-worker-01"  "192.168.1.221" 4096 2 50
create_vm 222 "k8s-worker-02"  "192.168.1.222" 4096 2 50
create_vm 223 "k8s-worker-03"  "192.168.1.223" 4096 2 50

# Para arrancar las VMs
echo "Arrancar todas las VMs con el siguiente comando:"
echo "for i in 0 1 2 3 do; qm start 22\$i; done"
