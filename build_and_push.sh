#!/bin/bash

# Definir tu nombre de usuario de Docker Hub
# NOTA: Reemplaza "yourusername" con tu nombre de usuario real de Docker Hub
DOCKER_USERNAME="sebasl07"

# Versión de las imágenes
VERSION="0.1.0"

# Lista de servicios
SERVICES=(
    "service-discovery"
    "cloud-config"
    "api-gateway"
    "proxy-client"
    "order-service"
    "payment-service"
    "product-service"
    "shipping-service"
    "user-service"
    "favourite-service"
)

# Función para construir y subir una imagen
build_and_push() {
    local service=$1
    local version=$2
    local username=$3
    
    echo "=========================================="
    echo "Construyendo $service:$version"
    echo "=========================================="
    
    # Construir la imagen
    docker build -t ${service}:${version} ./${service}
    
    # Etiquetar la imagen para Docker Hub
    docker tag ${service}:${version} ${username}/${service}-ecommerce-boot:${version}
    
    # Subir la imagen a Docker Hub
    echo "Subiendo ${username}/${service}-ecommerce-boot:${version} a Docker Hub"
    docker push ${username}/${service}-ecommerce-boot:${version}
    
    echo "Completado: ${service}"
    echo ""
}

# Iniciar sesión en Docker Hub
echo "Iniciando sesión en Docker Hub..."
echo "Por favor, ingresa tus credenciales de Docker Hub cuando se te solicite:"
docker login

# Construir y subir cada servicio
for service in "${SERVICES[@]}"; do
    build_and_push $service $VERSION $DOCKER_USERNAME
done

echo "=========================================="
echo "Todas las imágenes han sido construidas y subidas a Docker Hub"
echo "=========================================="

# Cerrar sesión de Docker Hub
docker logout
