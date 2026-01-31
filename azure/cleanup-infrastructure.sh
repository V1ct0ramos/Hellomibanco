#!/bin/bash

###############################################################################
# Script para eliminar todos los recursos de Azure
###############################################################################

set -e

RESOURCE_GROUP="rg-mibanco-helloworld"

echo "=========================================="
echo "ADVERTENCIA: Este script eliminará todos los recursos"
echo "=========================================="
echo "Resource Group: $RESOURCE_GROUP"
echo ""
read -p "¿Estás seguro? (yes/no): " CONFIRMAR

if [ "$CONFIRMAR" != "yes" ]; then
    echo "Operación cancelada."
    exit 0
fi

echo ""
echo "Eliminando Resource Group y todos sus recursos..."
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

echo "✓ Eliminación iniciada (proceso asíncrono)"
echo ""
echo "Para verificar el progreso:"
echo "az group show --name $RESOURCE_GROUP"
echo ""
