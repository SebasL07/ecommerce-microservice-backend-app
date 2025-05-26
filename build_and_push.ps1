# Obtener nombre de usuario de Docker Hub de la sesión actual
$DOCKER_USERNAME = (docker info | Select-String -Pattern "Username: (.+)" | ForEach-Object { $_.Matches.Groups[1].Value })

if ([string]::IsNullOrEmpty($DOCKER_USERNAME)) {
    Write-Host "ADVERTENCIA: No se detectó ninguna sesión en Docker. Si no has iniciado sesión, las imágenes no se podrán subir." -ForegroundColor Yellow
    $DOCKER_USERNAME = Read-Host -Prompt "Por favor, introduce tu nombre de usuario de Docker Hub"
}

Write-Host "Se usará el usuario: $DOCKER_USERNAME" -ForegroundColor Cyan

# Versión de las imágenes
$VERSION = "0.1.0"

# Lista de servicios
$SERVICES = @(
    "service-discovery",
    "cloud-config",
    "api-gateway",
    "proxy-client",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "user-service",
    "favourite-service"
)

# Función para construir y subir una imagen
function Build-And-Push {
    param (
        [string]$service,
        [string]$version,
        [string]$username
    )
    
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Construyendo $service`:$version" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    
    # Construir la imagen
    docker build -t ${service}:${version} ./${service}
    
    # Etiquetar la imagen para Docker Hub
    docker tag ${service}:${version} ${username}/${service}-ecommerce-boot:${version}
    
    # Subir la imagen a Docker Hub
    Write-Host "Subiendo ${username}/${service}-ecommerce-boot:${version} a Docker Hub" -ForegroundColor Yellow
    docker push ${username}/${service}-ecommerce-boot:${version}
    
    Write-Host "Completado: ${service}" -ForegroundColor Green
    Write-Host ""
}

# Construir y subir cada servicio
foreach ($service in $SERVICES) {
    Build-And-Push -service $service -version $VERSION -username $DOCKER_USERNAME
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Todas las imágenes han sido construidas y subidas a Docker Hub" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
