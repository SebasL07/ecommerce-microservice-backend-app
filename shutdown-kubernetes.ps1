# Shutdown-Kubernetes.ps1
# Script para detener todos los servicios de la aplicación de microservicios en Kubernetes
# Autor: GitHub Copilot
# Fecha: 31/05/2025

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "stage", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$Namespace = "default"
)

Write-Host "================ DETENIENDO SERVICIOS EN KUBERNETES ($Environment) ================" -ForegroundColor Green

# Función para mostrar la barra de progreso
function Show-Progress {
    param (
        [string]$Message,
        [int]$Steps = 10,
        [int]$Sleep = 100
    )
    
    Write-Host "$Message " -NoNewline
    
    for ($i = 0; $i -lt $Steps; $i++) {
        Write-Host "." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds $Sleep
    }
    
    Write-Host " ¡Completado!" -ForegroundColor Green
}

# Detectar sufijo en base al ambiente
$suffix = ""
if ($Environment -ne "dev") {
    $suffix = "-$Environment"
}

# Verificar si kubectl está disponible
try {
    $kubectl = kubectl version --client --output=json
    Write-Host "✅ kubectl detectado correctamente" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: kubectl no está instalado o configurado. Por favor, instálalo antes de ejecutar este script." -ForegroundColor Red
    exit 1
}

# Verificar que el clúster de Kubernetes esté accesible
try {
    $cluster = kubectl cluster-info
    Write-Host "✅ Conexión al clúster de Kubernetes establecida" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: No se puede conectar al clúster de Kubernetes. Verifica tu configuración." -ForegroundColor Red
    exit 1
}

# Listar los pods antes de detenerlos
Write-Host "`nPods actuales en el namespace '$Namespace':" -ForegroundColor Yellow
kubectl get pods -n $Namespace

# Detener servicios en orden inverso para minimizar errores
$services = @(
    "11-favourite-service",
    "10-user-service",
    "09-shipping-service",
    "08-product-service",
    "07-payment-service",
    "06-order-service",
    "05-proxy-client",
    "04-api-gateway",
    "03-cloud-config",
    "02-service-discovery",
    "01-zipkin"
)

# Eliminar cada servicio
foreach ($service in $services) {
    $yamlFile = "kubernetes/$Environment/$service$suffix.yaml"
    
    if (Test-Path $yamlFile) {
        Write-Host "`nDeteniendo $service..." -ForegroundColor Cyan
        
        try {
            kubectl delete -f $yamlFile -n $Namespace
            Show-Progress -Message "Esperando a que el servicio se detenga" -Steps 5 -Sleep 200
        }
        catch {
            Write-Host "⚠️ Advertencia: No se pudo detener $service. Es posible que ya esté detenido." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "⚠️ Advertencia: No se encontró el archivo $yamlFile" -ForegroundColor Yellow
    }
}

# Verificar que todos los servicios se hayan detenido
$remainingPods = kubectl get pods -n $Namespace -o jsonpath="{.items[*].metadata.name}" | Select-String -Pattern "order|payment|product|shipping|user|favourite|proxy|api-gateway|cloud-config|service-discovery|zipkin"

if ($remainingPods) {
    Write-Host "`n⚠️ Algunos pods siguen en ejecución. Forzando eliminación..." -ForegroundColor Yellow
    
    $remainingPodsList = $remainingPods -split " "
    foreach ($pod in $remainingPodsList) {
        Write-Host "Eliminando pod: $pod" -ForegroundColor Cyan
        kubectl delete pod $pod -n $Namespace --force --grace-period=0
    }
}

# Mostrar estado final
Write-Host "`nEstado final del namespace:" -ForegroundColor Yellow
kubectl get pods -n $Namespace

Write-Host "`n✅ Todos los servicios de la aplicación han sido detenidos en el ambiente $Environment" -ForegroundColor Green
Write-Host "Si deseas verificar que no queden recursos, ejecuta: kubectl get all -n $Namespace" -ForegroundColor Cyan
