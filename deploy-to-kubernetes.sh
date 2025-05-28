#!/bin/bash
# Script para desplegar los servicios en Kubernetes
# Fecha: 26 de mayo de 2025

# Configuración de tiempos de espera (en segundos) para cada servicio
declare -A WAIT_TIMES
WAIT_TIMES=(
    ["01-zipkin.yaml"]=10
    ["02-service-discovery.yaml"]=150  # Eureka necesita más tiempo para iniciar
    ["03-cloud-config.yaml"]=80       # Config Server también necesita tiempo
    ["04-api-gateway.yaml"]=30
    ["05-proxy-client.yaml"]=30
    ["06-order-service.yaml"]=20
    ["07-payment-service.yaml"]=15
    ["08-product-service.yaml"]=15
    ["09-shipping-service.yaml"]=15
    ["10-user-service.yaml"]=20
    ["11-favourite-service.yaml"]=0   # El último servicio no necesita espera
)

# Lista de archivos YAML en orden de aplicación
YAML_FILES=(
    "01-zipkin.yaml"
    "02-service-discovery.yaml"
    "03-cloud-config.yaml"
    "04-api-gateway.yaml"
    "05-proxy-client.yaml"
    "06-order-service.yaml"
    "07-payment-service.yaml"
    "08-product-service.yaml"
    "09-shipping-service.yaml"
    "10-user-service.yaml"
    "11-favourite-service.yaml"
)

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin Color

# Función para mostrar mensajes con formato
print_message() {
    local message=$1
    local color=$2
    echo -e "${color}${message}${NC}"
}

# Verificar si kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    print_message "Error: kubectl no está instalado o no está en el PATH." "$RED"
    print_message "Por favor, instale kubectl antes de ejecutar este script." "$RED"
    exit 1
fi

# Verificar conexión con el clúster
print_message "Verificando conexión al clúster de Kubernetes..." "$CYAN"
connection_attempts=0
max_attempts=3

while [ $connection_attempts -lt $max_attempts ]; do
    if kubectl cluster-info --request-timeout=30s &> /dev/null; then
        print_message "Conectado al clúster de Kubernetes." "$GREEN"
        break
    else
        connection_attempts=$((connection_attempts+1))
        if [ $connection_attempts -eq $max_attempts ]; then
            print_message "Error: No se pudo conectar al clúster de Kubernetes después de $max_attempts intentos." "$RED"
            print_message "Verifique que su configuración de kubectl esté correcta y que tenga acceso al clúster." "$RED"
            exit 1
        else
            print_message "Intento $connection_attempts de $max_attempts: No se pudo conectar al clúster. Intentando de nuevo en 5 segundos..." "$YELLOW"
            sleep 5
        fi
    fi
done

# Directorio de trabajo
KUBERNETES_DIR="$(dirname "$0")/kubernetes"

# Aplicar cada archivo YAML en orden
for yaml_file in "${YAML_FILES[@]}"; do
    yaml_path="${KUBERNETES_DIR}/${yaml_file}"
    
    # Verificar que el archivo existe
    if [ ! -f "$yaml_path" ]; then
        print_message "Advertencia: El archivo $yaml_file no existe. Omitiendo..." "$YELLOW"
        continue
    fi
    
    # Obtener el nombre del servicio a partir del nombre del archivo
    service_name=$(echo "$yaml_file" | sed -E 's/^[0-9]+-//' | sed 's/\.yaml$//')
    
    print_message "============================================" "$CYAN"
    print_message "Aplicando $yaml_file ($service_name)" "$CYAN"
    print_message "============================================" "$CYAN"
    
    # Aplicar el archivo YAML con validación desactivada para evitar problemas de TLS
    kubectl apply -f "$yaml_path" --validate=false
    
    if [ $? -ne 0 ]; then
        print_message "Error al aplicar $yaml_file. Intentando de nuevo sin validación." "$YELLOW"
        kubectl apply -f "$yaml_path" --validate=false --force
        
        if [ $? -ne 0 ]; then
            print_message "Error al aplicar $yaml_file. Verifique los logs para más detalles." "$RED"
            continue
        fi
    fi
    
    print_message "Servicio $service_name aplicado correctamente." "$GREEN"
    
    # Obtener el tiempo de espera para este servicio
    wait_time=${WAIT_TIMES[$yaml_file]}
    
    # Esperar antes de continuar con el siguiente servicio (excepto para el último)
    if [ "$yaml_file" != "${YAML_FILES[-1]}" ] && [ $wait_time -gt 0 ]; then
        print_message "Esperando $wait_time segundos antes de continuar con el siguiente servicio..." "$YELLOW"
        sleep $wait_time
    fi
done

print_message "============================================" "$GREEN"
print_message "Todos los servicios han sido desplegados en Kubernetes" "$GREEN"
print_message "============================================" "$GREEN"

# Mostrar todos los pods en el namespace ecommerce
print_message "Obteniendo estado de todos los pods:" "$CYAN"
kubectl get pods

# Mostrar todos los servicios en el namespace ecommerce
print_message "Obteniendo estado de todos los servicios:" "$CYAN"
kubectl get services

# Instrucciones para acceder a la aplicación
print_message "============================================" "$YELLOW"
print_message "Para acceder a la aplicación:" "$YELLOW"
print_message "1. API Gateway: kubectl port-forward service/api-gateway 8080:8080" "$YELLOW"
print_message "2. Service Discovery (Eureka): kubectl port-forward service/service-discovery 8761:8761" "$YELLOW"
print_message "3. Zipkin: kubectl port-forward service/zipkin 9411:9411" "$YELLOW"
print_message "============================================" "$YELLOW"
