# Entregables del Challenge

Lista de verificación de todos los entregables requeridos para el challenge técnico de Mibanco.

## ✅ 1. Código Fuente

### Repositorio GitHub
- [x] Código fuente completo en repositorio
- [x] Estructura de carpetas organizada
- [x] `.gitignore` configurado

### Archivos principales
- [x] `pom.xml` - Configuración Maven
- [x] `Dockerfile` - Imagen Docker multi-stage
- [x] `src/` - Código fuente Java/Spring Boot
- [x] `k8s/` - Manifiestos de Kubernetes
- [x] `azure/` - Scripts de infraestructura
- [x] `.github/workflows/` - Pipeline CI/CD

---

## ✅ 2. Aplicación

### Funcionalidad
- [x] Microservicio que retorna "Hola Mibanco"
- [x] Endpoint: `GET /`
- [x] Response: `Hola Mibanco`
- [x] Health check: `GET /health`

### Tecnología
- [x] Java 17
- [x] Spring Boot 3.2.1
- [x] Maven
- [x] Puerto 8080

---

## ✅ 3. Infraestructura Azure

### Recursos creados
- [x] Resource Group: `rg-mibanco-helloworld`
- [x] Azure Container Registry (ACR): `acrmibancohelloworld`
- [x] Azure Kubernetes Service (AKS): `aks-mibanco-helloworld`
- [x] NGINX Ingress Controller
- [x] LoadBalancer con IP pública

### Scripts
- [x] Script automatizado de creación (`setup-infrastructure.sh`)
- [x] Script de limpieza (`cleanup-infrastructure.sh`)
- [x] Documentación de infraestructura

---

## ✅ 4. Kubernetes Manifests

### Archivos requeridos
- [x] `deployment.yml` - Deployment con 2 réplicas
- [x] `service.yml` - Service tipo ClusterIP
- [x] `hpa.yml` - Horizontal Pod Autoscaler
- [x] `ingress.yml` - Ingress con NGINX

### Configuraciones
- [x] Health checks (liveness y readiness)
- [x] Resource limits (CPU y memoria)
- [x] Autoscaling: 2-10 réplicas
- [x] Variables para ACR y tag de imagen

---

## ✅ 5. GitHub Actions

### Pipeline CI/CD
- [x] Workflow `ci-cd.yml` configurado
- [x] Job: Build and Test
- [x] Job: Build and Push Docker Image
- [x] Job: Deploy to AKS
- [x] Validación automática de deployment

### Características
- [x] Se ejecuta en push a `main`
- [x] Compilación de microservicio
- [x] Build de imagen Docker
- [x] Push a ACR
- [x] Deploy automático a AKS
- [x] Validación de pods (`kubectl get pods`)

---

## ✅ 6. Metodología Trunk-Based

### Implementación
- [x] `main` como rama principal
- [x] CI ejecuta en cada push/PR
- [x] CD ejecuta solo en push a `main`
- [x] Branch protection configurado
- [x] Require PR approvals (1 reviewer mínimo)
- [x] Require status checks

---

## ✅ 7. Seguridad (Plus/Opcional)

### Implementaciones de seguridad
- [x] Usuario no-root en Docker
- [x] Multi-stage build (imagen mínima)
- [x] Health checks en Kubernetes
- [x] Resource limits en pods
- [x] Secrets management con GitHub Secrets
- [x] Service Principal con permisos específicos
- [x] ACR admin enabled solo para desarrollo

---

## 📸 8. Screenshots Requeridos

### Screenshot 1: Postman - Request exitoso
**Qué mostrar:**
- Método: GET
- URL: `http://<INGRESS-IP>/`
- Status: 200 OK
- Body: `Hola Mibanco`

**Cómo obtener:**
```bash
# Obtener IP del Ingress
kubectl get ingress helloworld-mibanco-ingress
# Usar esa IP en Postman
```

---

### Screenshot 2: GitHub Actions - Pipeline exitoso
**Qué mostrar:**
- Workflow completo ejecutado
- Los 3 jobs en verde:
  - ✅ Build and Test
  - ✅ Build and Push Docker Image
  - ✅ Deploy to AKS
- Tiempo de ejecución
- Commit que lo disparó

**Cómo obtener:**
1. Ve a GitHub → Actions
2. Click en el último workflow run
3. Captura mostrando todos los jobs completados

---

### Screenshot 3: Pods desplegados en AKS
**Qué mostrar:**
- Pods en estado `Running`
- Mínimo 2 réplicas
- Nombre, Ready, Status, Restarts, Age

**Comando:**
```bash
kubectl get pods -l app=helloworld-mibanco -o wide
```

**Captura esperada:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
helloworld-mibanco-xxxxxxxxxx-xxxxx   1/1     Running   0          5m
helloworld-mibanco-xxxxxxxxxx-xxxxx   1/1     Running   0          5m
```

---

### Screenshot 4: Deployment completo
**Qué mostrar:**
- Deployment status
- Service
- HPA
- Ingress con IP externa

**Comandos:**
```bash
kubectl get deployment helloworld-mibanco
kubectl get svc helloworld-mibanco-service
kubectl get hpa helloworld-mibanco-hpa
kubectl get ingress helloworld-mibanco-ingress
```

---

### Screenshot 5: Ingress funcionando
**Qué mostrar:**
- Ingress con IP externa asignada
- Backend correcto

**Comando:**
```bash
kubectl describe ingress helloworld-mibanco-ingress
```

---

### Screenshot 6: Curl desde terminal (Bonus)
**Qué mostrar:**
- Request curl al ingress
- Response: `Hola Mibanco`

**Comando:**
```bash
curl -v http://<INGRESS-IP>/
```

---

## 📦 9. Entrega Final

### Formato de entrega

**Opción 1: Repositorio GitHub (Recomendado)**
- URL del repositorio público
- README.md completo con instrucciones
- Screenshots en carpeta `docs/screenshots/`

**Opción 2: ZIP**
```
mibanco-challenge.zip
├── codigo-fuente/
│   └── [todo el código]
├── screenshots/
│   ├── 01-postman.png
│   ├── 02-github-actions.png
│   ├── 03-pods-aks.png
│   ├── 04-deployment.png
│   └── 05-ingress.png
└── README.md
```

---

## 📋 Checklist Final antes de Entregar

### Código
- [ ] Todo el código está en el repositorio
- [ ] `.gitignore` evita subir archivos innecesarios
- [ ] No hay secrets hardcodeados en el código
- [ ] README.md está actualizado y completo

### Infraestructura
- [ ] Scripts de Azure funcionan correctamente
- [ ] Todos los recursos están creados
- [ ] Documentación de infraestructura completa

### CI/CD
- [ ] Pipeline ejecuta exitosamente
- [ ] Todos los jobs pasan
- [ ] Deploy automático funciona

### Kubernetes
- [ ] Los 4 manifiestos están presentes
- [ ] Pods corren correctamente
- [ ] Ingress tiene IP pública
- [ ] HPA está configurado

### Screenshots
- [ ] Screenshot de Postman con respuesta correcta
- [ ] Screenshot de GitHub Actions pipeline completo
- [ ] Screenshot de pods en estado Running
- [ ] Screenshot de ingress con IP
- [ ] Screenshots en buena calidad (legibles)

### Documentación
- [ ] README.md principal completo
- [ ] Instrucciones de setup claras
- [ ] Documentación de cada componente
- [ ] Troubleshooting guide incluido

### Seguridad (Plus)
- [ ] GitHub Secrets configurados
- [ ] Branch protection activo
- [ ] PR approvals requeridos
- [ ] No hay credenciales expuestas

---

## ✅ Validación Final

Antes de entregar, ejecuta estos comandos para validar:

```bash
# 1. Validar aplicación local
mvn clean package && mvn spring-boot:run

# 2. Validar Docker
docker build -t test . && docker run -p 8080:8080 test

# 3. Validar recursos Azure
az group show --name rg-mibanco-helloworld
az acr list --resource-group rg-mibanco-helloworld
az aks list --resource-group rg-mibanco-helloworld

# 4. Validar AKS deployment
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get hpa

# 5. Validar endpoint
INGRESS_IP=$(kubectl get ingress helloworld-mibanco-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$INGRESS_IP/
```

Si todos estos comandos funcionan correctamente, **¡estás listo para entregar!** ✅

---

## 📞 Información de Contacto

Para cualquier duda sobre el challenge o la entrega, contacta al evaluador.

---

**Fecha de creación**: Enero 2026  
**Challenge**: Mibanco - DevOps Technical Challenge  
**Tecnologías**: Java, Spring Boot, Docker, Kubernetes, Azure, GitHub Actions
