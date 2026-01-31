# Infraestructura Azure para Mibanco Hello World

Este directorio contiene los scripts para crear y administrar la infraestructura en Azure.

## Prerrequisitos

- Azure CLI instalado ([Instalación](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- Helm 3 instalado ([Instalación](https://helm.sh/docs/intro/install/))
- kubectl instalado
- Cuenta de Azure activa

## Scripts

### setup-infrastructure.sh

Crea toda la infraestructura necesaria:
- Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- NGINX Ingress Controller

**Uso:**
```bash
# Dar permisos de ejecución
chmod +x azure/setup-infrastructure.sh

# Iniciar sesión en Azure
az login

# Ejecutar el script
./azure/setup-infrastructure.sh
```

**Recursos creados:**
- Resource Group: `rg-mibanco-helloworld`
- ACR: `acrmibancohelloworld`
- AKS: `aks-mibanco-helloworld` (2 nodos Standard_B2s)
- Ingress Controller: NGINX con LoadBalancer

### cleanup-infrastructure.sh

Elimina todos los recursos creados.

**Uso:**
```bash
chmod +x azure/cleanup-infrastructure.sh
./azure/cleanup-infrastructure.sh
```

## Configuración de GitHub Secrets

Después de ejecutar el script de setup, configura estos secrets en GitHub:

1. `AZURE_CREDENTIALS` - Credenciales del Service Principal
2. `ACR_LOGIN_SERVER` - `acrmibancohelloworld.azurecr.io`
3. `ACR_USERNAME` - Usuario del ACR (obtenido del script)
4. `ACR_PASSWORD` - Password del ACR (obtenido del script)
5. `AKS_RESOURCE_GROUP` - `rg-mibanco-helloworld`
6. `AKS_CLUSTER_NAME` - `aks-mibanco-helloworld`

## Verificar recursos

```bash
# Ver Resource Group
az group show --name rg-mibanco-helloworld

# Ver ACR
az acr list --resource-group rg-mibanco-helloworld --output table

# Ver AKS
az aks list --resource-group rg-mibanco-helloworld --output table

# Conectar a AKS
az aks get-credentials --resource-group rg-mibanco-helloworld --name aks-mibanco-helloworld

# Ver nodos
kubectl get nodes

# Ver ingress controller
kubectl get svc -n ingress-nginx
```

## Costos estimados

Con la configuración básica (2 nodos B2s):
- AKS: ~$60-80/mes
- ACR: ~$5/mes (Basic tier)
- LoadBalancer: ~$20/mes

**Total aproximado: $85-105 USD/mes**

## Notas

- Los nombres de los recursos deben ser únicos en Azure
- El ACR tiene admin habilitado para simplificar el acceso
- AKS usa identidad administrada para mayor seguridad
- El script tarda ~10-15 minutos en completarse
