# Guía de Configuración - Paso a Paso

Esta guía te llevará desde cero hasta tener la aplicación desplegada en Azure con CI/CD funcionando.

## ⏱️ Tiempo estimado: 30-40 minutos

---

## Fase 1: Preparación Local (5 minutos)

### 1.1 Verificar herramientas instaladas

```bash
# Java
java -version  # Debe ser 17+

# Maven
mvn -version   # Debe ser 3.9+

# Docker
docker --version

# Azure CLI
az --version

# kubectl
kubectl version --client

# Helm
helm version
```

### 1.2 Clonar y probar localmente

```bash
# Compilar
cd /home/jean-simon/Documents/helloworld
mvn clean package

# Ejecutar
mvn spring-boot:run

# En otra terminal, probar
curl http://localhost:8080/
# Debe retornar: Hola Mibanco
```

✅ **Checkpoint**: La aplicación funciona localmente

---

## Fase 2: Crear Infraestructura Azure (15 minutos)

### 2.1 Login en Azure

```bash
az login
```

Se abrirá el navegador para autenticarte.

### 2.2 Ejecutar script de setup

```bash
chmod +x azure/setup-infrastructure.sh
./azure/setup-infrastructure.sh
```

**Esto creará:**
- Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) - 2 nodos
- NGINX Ingress Controller

⏳ **Tiempo**: ~10-15 minutos

### 2.3 Guardar información importante

Al finalizar el script, guarda estos valores:

```
ACR Login Server: acrmibancohelloworld.azurecr.io
ACR Username: acrmibancohelloworld
ACR Password: [mostrado en output]
Ingress IP Externa: [mostrado en output]
```

✅ **Checkpoint**: Infraestructura creada en Azure

---

## Fase 3: Configurar GitHub (10 minutos)

### 3.1 Crear Service Principal

```bash
# Obtener Subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Crear Service Principal
az ad sp create-for-rbac \
  --name "sp-mibanco-helloworld-github" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-mibanco-helloworld \
  --sdk-auth
```

**Copia TODO el JSON** que devuelve (desde `{` hasta `}`).

### 3.2 Configurar GitHub Secrets

1. Ve a tu repositorio en GitHub
2. Click en `Settings` (en el menú superior)
3. En el menú lateral: `Secrets and variables` → `Actions`
4. Click en `New repository secret`

Agrega estos 6 secrets:

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | El JSON completo del Service Principal |
| `ACR_LOGIN_SERVER` | `acrmibancohelloworld.azurecr.io` |
| `ACR_USERNAME` | Del output del script (paso 2.3) |
| `ACR_PASSWORD` | Del output del script (paso 2.3) |
| `AKS_RESOURCE_GROUP` | `rg-mibanco-helloworld` |
| `AKS_CLUSTER_NAME` | `aks-mibanco-helloworld` |

### 3.3 Configurar Branch Protection

1. En GitHub: `Settings` → `Branches`
2. Click `Add branch protection rule`
3. Branch name pattern: `main`
4. Marcar:
   - ✅ `Require a pull request before merging`
   - ✅ `Require approvals` (1 reviewer mínimo)
   - ✅ `Require status checks to pass before merging`
   - ✅ `Require branches to be up to date before merging`
5. Click `Create`

✅ **Checkpoint**: GitHub configurado correctamente

---

## Fase 4: Primer Deploy (5-10 minutos)

### 4.1 Commit y push

```bash
# Verificar cambios
git status

# Agregar archivos
git add .

# Commit
git commit -m "Initial setup - Mibanco Hello World Challenge"

# Push a main (o crear PR según tu configuración)
git push origin main
```

### 4.2 Monitorear pipeline

1. Ve a GitHub → `Actions`
2. Verás el workflow `CI/CD Pipeline - Mibanco Hello World` ejecutándose
3. Click en el workflow para ver detalles
4. Observa los 3 jobs:
   - ✅ Build and Test
   - ✅ Build and Push Docker Image
   - ✅ Deploy to AKS

⏳ **Tiempo**: ~5-8 minutos

✅ **Checkpoint**: Pipeline ejecutado exitosamente

---

## Fase 5: Validación (5 minutos)

### 5.1 Verificar deployment en AKS

```bash
# Conectar a AKS
az aks get-credentials \
  --resource-group rg-mibanco-helloworld \
  --name aks-mibanco-helloworld \
  --overwrite-existing

# Ver pods
kubectl get pods
# Debe mostrar 2 pods en estado Running

# Ver deployment
kubectl get deployment helloworld-mibanco

# Ver service
kubectl get svc helloworld-mibanco-service

# Ver HPA
kubectl get hpa helloworld-mibanco-hpa

# Ver ingress y obtener IP
kubectl get ingress helloworld-mibanco-ingress
```

### 5.2 Probar aplicación

```bash
# Obtener IP del Ingress
INGRESS_IP=$(kubectl get ingress helloworld-mibanco-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Application URL: http://$INGRESS_IP"

# Probar
curl http://$INGRESS_IP/
# Debe retornar: Hola Mibanco
```

### 5.3 Prueba en Postman

1. Abre Postman
2. Crea un nuevo request:
   - Método: `GET`
   - URL: `http://<INGRESS_IP>/`
3. Click `Send`
4. Verifica:
   - Status: `200 OK`
   - Body: `Hola Mibanco`

**📸 Toma screenshot de Postman para el entregable**

✅ **Checkpoint**: Aplicación funcionando correctamente

---

## Fase 6: Screenshots para Entregables (5 minutos)

### Screenshot 1: Postman
- Request GET mostrando response "Hola Mibanco"
- ✅ Ya lo tienes del paso 5.3

### Screenshot 2: GitHub Actions Pipeline

```bash
# En GitHub
1. Ve a: Actions
2. Click en el último workflow ejecutado
3. Captura la pantalla mostrando los 3 jobs en verde
```

### Screenshot 3: Pods en AKS

```bash
kubectl get pods -o wide
# 📸 Captura mostrando pods en Running
```

### Screenshot 4: Deployment completo

```bash
# Un comando que muestra todo
kubectl get all -l app=helloworld-mibanco
kubectl get ingress helloworld-mibanco-ingress
# 📸 Captura mostrando todos los recursos
```

### Screenshot 5: Validación del endpoint

```bash
# Ejecutar y capturar
curl -v http://$INGRESS_IP/
# 📸 Captura mostrando el request y response
```

---

## 🎯 Checklist Final

- [ ] Aplicación funciona localmente
- [ ] Infraestructura Azure creada
- [ ] GitHub Secrets configurados
- [ ] Branch protection habilitado
- [ ] Pipeline ejecutado exitosamente
- [ ] Pods corriendo en AKS (2 réplicas)
- [ ] Ingress tiene IP pública
- [ ] Aplicación responde "Hola Mibanco"
- [ ] Screenshot de Postman
- [ ] Screenshot de GitHub Actions
- [ ] Screenshot de pods en AKS
- [ ] Screenshot de ingress

---

## 🔍 Troubleshooting

### Problema: Pipeline falla en "Azure Login"
**Solución**: Verifica que `AZURE_CREDENTIALS` esté correcto y tenga permisos de contributor

### Problema: Pods en estado ImagePullBackOff
**Solución**: 
```bash
# Verificar integración ACR-AKS
az aks update -n aks-mibanco-helloworld -g rg-mibanco-helloworld --attach-acr acrmibancohelloworld
```

### Problema: Ingress sin IP externa
**Solución**: Espera 2-3 minutos más, el LoadBalancer tarda en asignar la IP

### Problema: 404 al acceder a la IP del Ingress
**Solución**: 
```bash
# Verificar ingress
kubectl describe ingress helloworld-mibanco-ingress

# Verificar que el servicio funciona
kubectl port-forward svc/helloworld-mibanco-service 8080:80
curl http://localhost:8080/
```

---

## 🧹 Limpieza (Opcional)

Cuando termines las pruebas y quieras eliminar todo:

```bash
chmod +x azure/cleanup-infrastructure.sh
./azure/cleanup-infrastructure.sh
```

Esto elimina:
- Resource Group completo
- ACR
- AKS
- Todos los recursos asociados

---

## 📞 Comandos útiles

```bash
# Ver logs de pods
kubectl logs -l app=helloworld-mibanco --tail=50

# Describir un pod
kubectl describe pod <pod-name>

# Ver eventos del cluster
kubectl get events --sort-by=.metadata.creationTimestamp

# Redeployar manualmente
kubectl rollout restart deployment/helloworld-mibanco

# Ver status del rollout
kubectl rollout status deployment/helloworld-mibanco

# Ver métricas
kubectl top nodes
kubectl top pods
```

---

## ✅ ¡Felicidades!

Has completado el challenge técnico con éxito. Tienes:

✅ Microservicio Java funcionando  
✅ CI/CD automatizado con GitHub Actions  
✅ Infraestructura en Azure (AKS + ACR)  
✅ Trunk-based development implementado  
✅ Branch protection y PR approvals  
✅ Manifiestos completos de Kubernetes  
✅ Autoscaling configurado (HPA)  
✅ Ingress Controller funcionando  
✅ Screenshots para el entregable
