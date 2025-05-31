#!/bin/bash
# shutdown-kubernetes.sh
# Script para detener todos los servicios de la aplicación de microservicios en Kubernetes
# Autor: GitHub Copilot
# Fecha: 31/05/2025

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parámetros del script
ENVIRONMENT=${1:-dev}
NAMESPACE=${2:-default}

echo -e "${GREEN}================ DETENIENDO SERVICIOS EN KUBERNETES ($ENVIRONMENT) =================${NC}"

# Función para mostrar progreso
show_progress() {
    local message=$1
    local steps=${2:-10}
    local sleep_time=${3:-0.1}
    
    echo -n -e "${message} "
    
    for ((i=0; i<steps; i++)); do
        echo -n -e "${CYAN}.${NC}"
        sleep $sleep_time
    done
    
    echo -e " ${GREEN}¡Completado!${NC}"
}

# Detectar sufijo en base al ambiente
SUFFIX=""
if [ "$ENVIRONMENT" != "dev" ]; then
    SUFFIX="-${ENVIRONMENT}"
fi

# Verificar si kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ Error: kubectl no está instalado o configurado. Por favor, instálalo antes de ejecutar este script.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ kubectl detectado correctamente${NC}"
fi

# Verificar que el clúster de Kubernetes esté accesible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Error: No se puede conectar al clúster de Kubernetes. Verifica tu configuración.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Conexión al clúster de Kubernetes establecida${NC}"
fi

# Listar los pods antes de detenerlos
echo -e "\n${YELLOW}Pods actuales en el namespace '$NAMESPACE':${NC}"
kubectl get pods -n $NAMESPACE

# Detener servicios en orden inverso para minimizar errores
SERVICES=(
    "11-favourite-service"
    "10-user-service"
    "09-shipping-service"
    "08-product-service"
    "07-payment-service"
    "06-order-service"
    "05-proxy-client"
    "04-api-gateway"
    "03-cloud-config"
    "02-service-discovery"
    "01-zipkin"
)

# Eliminar cada servicio
for service in "${SERVICES[@]}"; do
    YAML_FILE="kubernetes/${ENVIRONMENT}/${service}${SUFFIX}.yaml"
    
    if [ -f "$YAML_FILE" ]; then
        echo -e "\n${CYAN}Deteniendo ${service}...${NC}"
        
        if kubectl delete -f $YAML_FILE -n $NAMESPACE 2>/dev/null; then
            show_progress "Esperando a que el servicio se detenga" 5 0.2
        else
            echo -e "${YELLOW}⚠️ Advertencia: No se pudo detener $service. Es posible que ya esté detenido.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Advertencia: No se encontró el archivo $YAML_FILE${NC}"
    fi
done

# Verificar que todos los servicios se hayan detenido
REMAINING_PODS=$(kubectl get pods -n $NAMESPACE -o jsonpath="{.items[*].metadata.name}" 2>/dev/null | grep -E 'order|payment|product|shipping|user|favourite|proxy|api-gateway|cloud-config|service-discovery|zipkin')

if [ ! -z "$REMAINING_PODS" ]; then
    echo -e "\n${YELLOW}⚠️ Algunos pods siguen en ejecución. Forzando eliminación...${NC}"
    
    for pod in $REMAINING_PODS; do
        echo -e "${CYAN}Eliminando pod: $pod${NC}"
        kubectl delete pod $pod -n $NAMESPACE --force --grace-period=0
    done
fi

# Mostrar estado final
echo -e "\n${YELLOW}Estado final del namespace:${NC}"
kubectl get pods -n $NAMESPACE

echo -e "\n${GREEN}✅ Todos los servicios de la aplicación han sido detenidos en el ambiente $ENVIRONMENT${NC}"
echo -e "${CYAN}Si deseas verificar que no queden recursos, ejecuta: kubectl get all -n $NAMESPACE${NC}"
