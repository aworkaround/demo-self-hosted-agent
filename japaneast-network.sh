#!/bin/bash


## US EAST NETWORK ##
LOCATION='japaneast'
NETWORK_ID='10.0.0'
VNET_CIDR='16'
SNET_CIDR='24'
NETWORK="my-$LOCATION-network"
VM_NAME="my-$LOCATION-vm"
SUBNET_NAME='subnet01'
ADDRESS_PREFIX="$NETWORK_ID.0/$VNET_CIDR"
SUBNET_PREFIX="$NETWORK_ID.0/$SNET_CIDR"
VM_IP_ADDRESS="$NETWORK_ID.9"
USERNAME='kamal'

echo 'Creating Resource Group...'
az group create --name "$NETWORK-rg" --location $LOCATION > /dev/null

echo 'Creating Virtual Network...'
az network vnet create \
            --name "$NETWORK-vnet" \
            --resource-group "$NETWORK-rg" \
            --address-prefixes $ADDRESS_PREFIX \
            --location $LOCATION \
            --subnet-name $SUBNET_NAME \
            --subnet-prefixes $SUBNET_PREFIX \
            > /dev/null

echo 'Creating Network Security Group...'
az network nsg create \
            --name "$NETWORK-nsg" \
            --resource-group "$NETWORK-rg" \
            --location $LOCATION \
            > /dev/null

echo 'Creating NSG Rule to allow SSH...'
az network nsg rule create \
            --name 'AllowSSH' \
            --nsg-name "$NETWORK-nsg" \
            --priority 4000 \
            --resource-group "$NETWORK-rg" \
            --description 'Rule Allows the SSH connections on Port:22 from Internet.' \
            --destination-port-ranges 22 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            > /dev/null

echo 'Adding NSG to Subnet...'
az network vnet subnet update \
            --network-security-group "$NETWORK-nsg" \
            --resource-group "$NETWORK-rg" \
            --name $SUBNET_NAME \
            --vnet-name "$NETWORK-vnet" \
            > /dev/null

echo 'Creating Public IP Address...'
az network public-ip create \
            --name "$VM_NAME-pip" \
            --location $LOCATION \
            --resource-group "$NETWORK-rg" \
            --allocation-method Static \
            --sku Standard \
            > /dev/null


PIP_ID=$(az network public-ip show --resource-group "$NETWORK-rg" --name "$VM_NAME-pip" --query "id" --output tsv)

echo 'Creating Virtual Machine...'
az network nic create \
            --name "$VM_NAME-nic" \
            --resource-group "$NETWORK-rg" \
            --vnet-name "$NETWORK-vnet" \
            --subnet $SUBNET_NAME \
            --location $LOCATION \
            --private-ip-address $VM_IP_ADDRESS \
            --public-ip-address $PIP_ID \
            > /dev/null

PIP=$(az vm create \
            --name $VM_NAME \
            --location $LOCATION \
            --resource-group "$NETWORK-rg" \
            --admin-username $USERNAME \
            --authentication-type ssh \
            --computer-name $VM_NAME \
            --size Standard_B1s \
            --generate-ssh-keys \
            --image UbuntuLTS \
            --os-disk-name "$VM_NAME-os-disk"\
            --os-disk-size-gb 30 -o jsonc \
            --nics "$VM_NAME-nic" \
            --output tsv \
            --query "publicIpAddress" \
            )

echo "VM Created Successfully. You can connect by running command: ssh $USERNAME@$PIP"