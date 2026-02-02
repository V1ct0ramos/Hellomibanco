# Mibanco Hello World - Challenge Técnico

Microservicio Java con Spring Boot y CI/CD automatizado usando GitHub Actions y Azure Kubernetes Service (AKS).

## 📋 Descripción

Aplicación de demostración que expone un endpoint REST que retorna "Hola Mibanco". Incluye:

- ✅ Microservicio Java con Spring Boot
- ✅ Contenedorización con Docker
- ✅ Despliegue en Azure Kubernetes Service (AKS)
- ✅ CI/CD automatizado con GitHub Actions
- ✅ Manifiestos completos de Kubernetes (Deployment, Service, HPA, Ingress)
- ✅ Infraestructura como código (Azure CLI)
- ✅ Trunk-based development
- ✅ Branch protection con PR approvals

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Actions                        │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Build   │→ │ Docker Build │→ │  Deploy to AKS       │  │
│  │  & Test  │  │  & Push ACR  │  │  + Validation        │  │
│  └──────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌──────────────────────────────────────┐
        │   Azure Container Registry (ACR)      │
        │   acrmibancohelloworld.azurecr.io    │
        └──────────────────────────────────────┘
                            ↓
        ┌──────────────────────────────────────┐
        │  Azure Kubernetes Service (AKS)      │
        │  ┌────────────────────────────────┐  │
        │  │  NGINX Ingress Controller      │  │
        │  └────────────────────────────────┘  │
        │  ┌────────────────────────────────┐  │
        │  │  Pods (2-10 réplicas + HPA)    │  │
        │  │  helloworld-mibanco            │  │
        │  └────────────────────────────────┘  │
        └──────────────────────────────────────┘
                            ↓
                    ┌──────────────┐
                    │   Public IP  │
                    │  LoadBalancer│
                    └──────────────┘
```

## 🚀 Quick Start

### Prerrequisitos

- ✅ Java 17
- ✅ Maven 3.9+
- ✅ Docker
- ✅ Azure CLI
- ✅ kubectl
- ✅ Helm 3
- ✅ Cuenta de Azure (Free tier)
- ✅ Cuenta de GitHub

### 1. Ejecutar localmente

```bash
# Compilar
mvn clean package

# Ejecutar
mvn spring-boot:run

# Probar
curl http://localhost:8080/
# Respuesta: Hola Mibanco
```

### 2. Ejecutar con Docker

```bash
# Build
docker build -t helloworld-mibanco:latest .

# Run
docker run -p 8080:8080 helloworld-mibanco:latest

# Test
curl http://localhost:8080/
```

## ☁️ Despliegue en Azure

### Paso 1: Crear infraestructura

```bash
# Login a Azure
az login

# Dar permisos de ejecución
chmod +x azure/setup-infrastructure.sh

# Ejecutar script (tarda ~10-15 minutos)
./azure/setup-infrastructure.sh
```

Esto crea:
- Resource Group: `rg-mibanco-helloworld`
- ACR: `acrmibancohelloworld.azurecr.io`
- AKS: `aks-mibanco-helloworld` (2 nodos)
- NGINX Ingress Controller

### Paso 2: Configurar GitHub Secrets

Crea un Service Principal:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az ad sp create-for-rbac \
  --name "sp-mibanco-helloworld-github" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-mibanco-helloworld \
  --sdk-auth
```

En GitHub, ve a `Settings → Secrets and variables → Actions` y agrega:

| Secret | Valor |
|--------|-------|
| `AZURE_CREDENTIALS` | JSON completo del Service Principal |
| `ACR_LOGIN_SERVER` | `acrmibancohelloworld.azurecr.io` |
| `ACR_USERNAME` | Usuario del ACR (del script output) |
| `ACR_PASSWORD` | Password del ACR (del script output) |
| `AKS_RESOURCE_GROUP` | `rg-mibanco-helloworld` |
| `AKS_CLUSTER_NAME` | `aks-mibanco-helloworld` |

### Paso 3: Configurar Branch Protection

1. Ve a `Settings → Branches → Add rule`
2. Branch name pattern: `main`
3. Marca:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 reviewer)
   - ✅ Require status checks to pass before merging
4. Save changes

### Paso 4: Trigger Pipeline

```bash
# Commit y push a main
git add .
git commit -m "Initial setup"
git push origin main
```

El pipeline se ejecutará automáticamente:
1. Build y test de la aplicación
2. Build y push de imagen Docker a ACR
3. Deploy a AKS
4. Validación de pods y endpoint

### Paso 5: Verificar deployment

```bash
# Conectar a AKS
az aks get-credentials --resource-group rg-mibanco-helloworld --name aks-mibanco-helloworld

# Ver pods
kubectl get pods

# Ver ingress y obtener IP
kubectl get ingress helloworld-mibanco-ingress

# Probar aplicación (reemplaza con la IP del ingress)
curl http://<INGRESS-IP>/
```

## 📁 Estructura del proyecto

```
helloworld/
├── src/
│   └── main/
│       ├── java/com/mibanco/helloworld/
│       │   ├── HelloWorldApplication.java
│       │   └── controller/
│       │       └── HelloController.java
│       └── resources/
│           └── application.properties
├── k8s/
│   ├── deployment.yml          # Deployment con health checks
│   ├── service.yml             # ClusterIP service
│   ├── hpa.yml                 # Horizontal Pod Autoscaler
│   └── ingress.yml             # NGINX Ingress
├── azure/
│   ├── setup-infrastructure.sh # Crear recursos Azure
│   ├── cleanup-infrastructure.sh # Eliminar recursos Azure
│   └── README.md
├── .github/
│   └── workflows/
│       ├── ci-cd.yml           # Pipeline completo
│       └── README.md
├── Dockerfile                  # Multi-stage build
├── .dockerignore
├── pom.xml
└── README.md
```

## 🔄 Flujo CI/CD

### Trunk-Based Development

- **Main branch**: Rama principal, siempre deployable
- **Feature branches**: Ramas de corta duración
- **Pull Requests**: Requieren aprobación antes de merge
- **CI**: Ejecuta en cada push/PR
- **CD**: Deploy automático en merge a main

### Pipeline Steps

```
1. Build & Test
   ├── Checkout code
   ├── Setup Java 17
   ├── Maven build
   ├── Run tests
   └── Upload artifact

2. Build Docker Image (solo main)
   ├── Generate unique tag
   ├── Login to ACR
   ├── Build image
   └── Push to ACR

3. Deploy to AKS (solo main)
   ├── Azure login
   ├── Set AKS context
   ├── Replace variables
   ├── Apply manifests
   ├── Wait for rollout
   ├── Validate deployment
   └── Test endpoint
```

## 🧪 Testing

### Prueba local del endpoint

```bash
curl http://localhost:8080/
# Respuesta: Hola Mibanco

curl http://localhost:8080/health
# Respuesta: OK
```

### Prueba en Postman

1. Método: `GET`
2. URL: `http://<INGRESS-IP>/` o `http://localhost:8080/`
3. Respuesta esperada:
   ```
   Status: 200 OK
   Body: Hola Mibanco
   ```

### Prueba en AKS

```bash
# Port forward
kubectl port-forward deployment/helloworld-mibanco 8080:8080

# En otra terminal
curl http://localhost:8080/
```

## 📊 Monitoreo

```bash
# Ver logs
kubectl logs -l app=helloworld-mibanco --tail=100 -f

# Ver métricas de pods
kubectl top pods

# Ver estado del HPA
kubectl get hpa helloworld-mibanco-hpa

# Ver eventos
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 🔒 Seguridad (Opcional/Plus)

Implementaciones incluidas:

- ✅ Usuario no-root en Docker
- ✅ Multi-stage build (imagen mínima)
- ✅ Health checks en Kubernetes
- ✅ Resource limits en pods
- ✅ Service Principal con permisos específicos
- ✅ Secrets management con GitHub Secrets

Mejoras adicionales sugeridas:

- 🔐 Network Policies en Kubernetes
- 🔐 Pod Security Standards
- 🔐 Azure Key Vault para secrets
- 🔐 Image scanning con Trivy
- 🔐 HTTPS con cert-manager

## 🧹 Limpieza

Para eliminar todos los recursos de Azure:

```bash
chmod +x azure/cleanup-infrastructure.sh
./azure/cleanup-infrastructure.sh
```

Esto elimina el Resource Group completo y todos sus recursos.

## 📸 Entregables del Challenge

### ✅ Código fuente
- Repositorio completo en GitHub
- Todos los archivos versionados

### ✅ Screenshots necesarios

1. **Postman**: GET request mostrando "Hola Mibanco"
2. **GitHub Actions**: Pipeline ejecutándose exitosamente
3. **AKS Pods**: `kubectl get pods` mostrando pods running
4. **Ingress**: `kubectl get ingress` mostrando IP externa

### ✅ Comandos para screenshots

```bash
# Para screenshot de pods
kubectl get pods -o wide

# Para screenshot de deployment
kubectl get deployment helloworld-mibanco

# Para screenshot de ingress
kubectl get ingress helloworld-mibanco-ingress

# Para screenshot de HPA
kubectl get hpa

# Para screenshot de services
kubectl get svc
```

## 🛠️ Tecnologías utilizadas

- **Backend**: Java 17, Spring Boot 3.2.1
- **Build**: Maven 3.9.6
- **Containerización**: Docker (multi-stage)
- **Orquestación**: Kubernetes (AKS)
- **Cloud**: Microsoft Azure
- **CI/CD**: GitHub Actions
- **Ingress**: NGINX Ingress Controller
- **Infraestructura**: Azure CLI (Bash scripts)

## 📚 Documentación adicional

- [Azure Setup Guide](azure/README.md)
- [GitHub Actions Guide](.github/workflows/README.md)
- [Kubernetes Manifests](k8s/)

## 👤 Autor

Challenge técnico para Mibanco

## 📄 Licencia

Este proyecto es para fines de evaluación técnica.
Reto Tecnico
