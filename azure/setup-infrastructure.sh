#!/bin/bash

###############################################################################
# Script para crear la infraestructura de Azure para Mibanco Hello World
# Recursos: Resource Group, ACR, AKS, Ingress Controller
###############################################################################

set -e  # Exit on error

# Variables de configuración
RESOURCE_GROUP="rg-mibanco-helloworld"
LOCATION="eastus"
ACR_NAME="acrmibancohelloworld"
AKS_NAME="aks-mibanco-helloworld"
AKS_NODE_COUNT=1
AKS_NODE_SIZE="Standard_DC2s_v3"

echo "=========================================="
echo "Creando infraestructura de Azure"
echo "=========================================="

# Verificar login en Azure
echo "Verificando login en Azure..."
az account show > /dev/null 2>&1 || {
    echo "Error: No has iniciado sesión en Azure. Ejecuta: az login"
    exit 1
}

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "✓ Suscripción activa: $SUBSCRIPTION_ID"

# 1. Crear Resource Group
echo ""
echo "[1/4] Creando Resource Group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output table

echo "✓ Resource Group creado: $RESOURCE_GROUP"

# 2. Crear Azure Container Registry (ACR)
echo ""
echo "[2/4] Creando Azure Container Registry..."
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true \
    --output table

echo "✓ ACR creado: $ACR_NAME"

# Obtener credenciales del ACR
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

echo "  ACR Login Server: ${ACR_NAME}.azurecr.io"
echo "  ACR Username: $ACR_USERNAME"

# 3. Crear Azure Kubernetes Service (AKS)
echo ""
echo "[3/4] Creando Azure Kubernetes Service (esto puede tardar varios minutos)..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --node-count $AKS_NODE_COUNT \
    --node-vm-size $AKS_NODE_SIZE \
    --enable-managed-identity \
    --generate-ssh-keys \
    --attach-acr $ACR_NAME \
    --network-plugin azure \
    --enable-addons monitoring \
    --output table

echo "✓ AKS creado: $AKS_NAME"

# Obtener credenciales de AKS
echo ""
echo "Obteniendo credenciales de AKS..."
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --overwrite-existing

echo "✓ Credenciales de AKS configuradas"

# Verificar conexión al cluster
echo ""
echo "Verificando conexión al cluster..."
kubectl cluster-info
kubectl get nodes

# 4. Instalar Ingress Controller (NGINX)
echo ""
echo "[4/4] Instalando NGINX Ingress Controller..."

# Agregar repositorio de Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Instalar NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.type=LoadBalancer \
    --set controller.service.externalTrafficPolicy=Local

echo "✓ NGINX Ingress Controller instalado"

# Esperar a que el LoadBalancer obtenga una IP externa
echo ""
echo "Esperando IP externa del LoadBalancer (esto puede tardar un par de minutos)..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=300s

# Obtener IP externa
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    echo "Esperando IP externa..."
    EXTERNAL_IP=$(kubectl get service nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    [ -z "$EXTERNAL_IP" ] && sleep 10
done

echo ""
echo "=========================================="
echo "✓ Infraestructura creada exitosamente"
echo "=========================================="
echo ""
echo "INFORMACIÓN DE RECURSOS:"
echo "------------------------"
echo "Resource Group:       $RESOURCE_GROUP"
echo "ACR Name:             $ACR_NAME"
echo "ACR Login Server:     ${ACR_NAME}.azurecr.io"
echo "AKS Name:             $AKS_NAME"
echo "AKS Nodes:            $AKS_NODE_COUNT"
echo "Ingress IP Externa:   $EXTERNAL_IP"
echo ""
echo "=========================================="
echo "GITHUB SECRETS - Agrega estos 6 secrets:"
echo "=========================================="
echo ""
echo "1. ACR_LOGIN_SERVER"
echo "   ${ACR_NAME}.azurecr.io"
echo ""
echo "2. ACR_USERNAME"
echo "   $ACR_USERNAME"
echo ""
echo "3. ACR_PASSWORD"
echo "   $ACR_PASSWORD"
echo ""
echo "4. AKS_RESOURCE_GROUP"
echo "   $RESOURCE_GROUP"
echo ""
echo "5. AKS_CLUSTER_NAME"
echo "   $AKS_NAME"
echo ""
echo "COMANDO PARA CREAR EL SERVICE PRINCIPAL:"
echo ""
echo "=========================================="
echo "6. AZURE_CREDENTIALS (ejecutar este comando):"
echo "   az ad sp create-for-rbac \\"
echo "     --name \"sp-mibanco-helloworld-github\" \\"
echo "     --role contributor \\"
echo "     --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \\"
echo "     --sdk-auth"
echo ""
echo "   Copia TODO el JSON que devuelva el comando anterior"
echo ""
echo "=========================================="
echo ""

