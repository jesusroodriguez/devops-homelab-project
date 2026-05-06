#!/bin/bash
# create-template.sh
# Crea la VM template de ubuntu 24.04
# Este script se lanza desde el host proxmox (192.168.1.210)

set -e

TEMPLATE_ID=1000
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_DIR="/var/lib/vz/template/iso"
IMAGE_FILE="noble-server-cloudimg-amd64.img"
STORAGE="local-lvm"

echo "====================================="
echo "Creando la VM template Ubuntu 24.04"
echo "Template ID: $TEMPLATE_ID"
echo "====================================="

# Descargar la imagen
echo ""
echo "Descargando Ubuntu 24.04 cloud image..."
cd "$IMAGE_DIR"
if [ -f "$IMAGE_FILE" ]; then
    echo "Ya existe la imagen. Se salta la descarga."
else
    wget "$IMAGE_URL"
    echo "Descarga completa: $(ls -lh $IMAGE_FILE)"
fi

# Crear VM
echo ""
echo "Creando el template..."
qm create $TEMPLATE_ID \
    --name ubuntu-24.04-template \
    --memory 2048 \
    --cores 2 \
    --net0 virtio,bridge=vmbr0

# Importo el disco de cloud init
echo ""
echo "Importando el disco de cloud init a la VM..."
qm importdisk $TEMPLATE_ID "$IMAGE_DIR/$IMAGE_FILE" $STORAGE

# Configuro la VM
echo ""
echo "Configurando VM..."
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --ide2 $STORAGE:cloudinit
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent enabled=1

# Configuro los defaults de Cloud-Init
echo ""
echo "Configurando defaults de cloud init..."
qm set $TEMPLATE_ID --ciuser remote
qm set $TEMPLATE_ID --cipassword $(openssl passwd -6 "remote")

# Configuro las ssh keys
if [ -f ~/.ssh/id_ed25519.pub ]; then
    echo "Utilizo la ssh key de ~/.ssh/id_ed25519.pub"
    qm set $TEMPLATE_ID --sshkeys ~/.ssh/id_ed25519.pub
else
    echo "WARNING: No se ha encontrado la ssh key: Añadela a mano"
    echo "  qm set $TEMPLATE_ID --sshkeys ~/.ssh/ssh_key.pub"
fi

qm set $TEMPLATE_ID --ipconfig0 ip=dhcp

# Convierto a template
echo ""
echo "Convirtiendo la VM en template..."
qm template $TEMPLATE_ID

echo ""
echo "====================================="
echo "✓ Plantilla creada satisfactoriamente!"
echo "====================================="
echo "Template ID: $TEMPLATE_ID"
echo "Template Name: ubuntu-24.04-template"
echo ""
