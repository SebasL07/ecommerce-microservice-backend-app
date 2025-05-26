# Script para desplegar los servicios en Kubernetes
# Autor: GitHub Copilot
# Fecha: 25 de mayo de 2025

# Configuración
$waitTimeInSeconds = 30  # Tiempo de espera entre servicios

# Lista de archivos YAML en orden de aplicación
$yamlFiles = @(
    "01-zipkin.yaml",
    "02-service-discovery.yaml",
    "03-cloud-config.yaml",
    "04-api-gateway.yaml",
    "05-proxy-client.yaml",
    "06-order-service.yaml",
    "07-payment-service.yaml",
    "08-product-service.yaml",
    "09-shipping-service.yaml",
    "10-user-service.yaml",
    "11-favourite-service.yaml"
)

# Función para mostrar mensajes con formato
function Write-ColorOutput {
    param(
        [string]$message,
        [string]$color = "White"
    )
    Write-Host $message -ForegroundColor $color
}

# Función para verificar si kubectl está instalado
function Check-KubectlInstalled {
    try {
        $null = kubectl version --client
        return $true
    }
    catch {
        return $false
    }
}

# Verificar si kubectl está instalado
if (-not (Check-KubectlInstalled)) {
    Write-ColorOutput "Error: kubectl no está instalado o no está en el PATH." "Red"
    Write-ColorOutput "Por favor, instale kubectl antes de ejecutar este script." "Red"
    exit 1
}

# Verificar conexión con el clúster
try {
    $null = kubectl cluster-info
    Write-ColorOutput "Conectado al clúster de Kubernetes." "Green"
}
catch {
    Write-ColorOutput "Error: No se pudo conectar al clúster de Kubernetes." "Red"
    Write-ColorOutput "Verifique que su configuración de kubectl esté correcta y que tenga acceso al clúster." "Red"
    exit 1
}

# Directorio de trabajo
$kubernetesDir = Join-Path -Path $PSScriptRoot -ChildPath "kubernetes"

# Aplicar cada archivo YAML en orden
foreach ($yamlFile in $yamlFiles) {
    $yamlPath = Join-Path -Path $kubernetesDir -ChildPath $yamlFile
    
    # Verificar que el archivo existe
    if (-not (Test-Path $yamlPath)) {
        Write-ColorOutput "Advertencia: El archivo $yamlFile no existe. Omitiendo..." "Yellow"
        continue
    }
    
    # Obtener el nombre del servicio a partir del nombre del archivo
    $serviceName = $yamlFile -replace "^\d+-", "" -replace "\.yaml$", ""
    
    Write-ColorOutput "============================================" "Cyan"
    Write-ColorOutput "Aplicando $yamlFile ($serviceName)" "Cyan"
    Write-ColorOutput "============================================" "Cyan"
    
    # Aplicar el archivo YAML
    kubectl apply -f $yamlPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "Error al aplicar $yamlFile. Verifique los logs para más detalles." "Red"
        continue
    }
    
    Write-ColorOutput "Servicio $serviceName aplicado correctamente." "Green"
    
    # Esperar antes de continuar con el siguiente servicio (excepto para el último)
    if ($yamlFile -ne $yamlFiles[-1]) {
        Write-ColorOutput "Esperando $waitTimeInSeconds segundos antes de continuar con el siguiente servicio..." "Yellow"
        Start-Sleep -Seconds $waitTimeInSeconds
    }
}

Write-ColorOutput "============================================" "Green"
Write-ColorOutput "Todos los servicios han sido desplegados en Kubernetes" "Green"
Write-ColorOutput "============================================" "Green"

# Mostrar todos los pods en el namespace ecommerce
Write-ColorOutput "Obteniendo estado de todos los pods:" "Cyan"
kubectl get pods

# Mostrar todos los servicios en el namespace ecommerce
Write-ColorOutput "Obteniendo estado de todos los servicios:" "Cyan"
kubectl get services

# Instrucciones para acceder a la aplicación
Write-ColorOutput "============================================" "Yellow"
Write-ColorOutput "Para acceder a la aplicación:" "Yellow"
Write-ColorOutput "1. API Gateway: kubectl port-forward service/api-gateway 8080:8080" "Yellow"
Write-ColorOutput "2. Service Discovery (Eureka): kubectl port-forward service/service-discovery 8761:8761" "Yellow"
Write-ColorOutput "3. Zipkin: kubectl port-forward service/zipkin 9411:9411" "Yellow"
Write-ColorOutput "============================================" "Yellow"
