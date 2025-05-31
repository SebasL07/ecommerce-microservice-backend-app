#!/bin/bash
# filepath: /home/camilin/Documents/Icesi/ingesoft/ecommerce-microservice-backend-app/deploy-jenkins.sh

# Script para desplegar Jenkins en Kubernetes (Minikube)

# Default values
NAMESPACE="default"
OPEN_BROWSER=true

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Parse command line arguments
while getopts "n:h" opt; do
    case $opt in
        n)
            NAMESPACE="$OPTARG"
            ;;
        h)
            echo "Usage: $0 [-n namespace] [-h]"
            echo "  -n namespace: Kubernetes namespace (default: default)"
            echo "  -h: Show help"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Check for --no-browser flag
for arg in "$@"; do
    if [[ "$arg" == "--no-browser" ]]; then
        OPEN_BROWSER=false
        break
    fi
done

echo -e "${CYAN}===== DESPLEGANDO JENKINS EN KUBERNETES =====${NC}"

# Verificar si Minikube está corriendo
if ! minikube status &>/dev/null; then
    echo -e "${YELLOW}Minikube no está en ejecución. Iniciando Minikube...${NC}"
    minikube start --cpus=no-limit --memory=no-limit
fi

# Si se especificó un namespace diferente a default, crearlo si no existe
if [[ "$NAMESPACE" != "default" ]]; then
    if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
        echo -e "${YELLOW}Creando namespace $NAMESPACE...${NC}"
        kubectl create namespace "$NAMESPACE"
    else
        echo -e "${YELLOW}Usando namespace existente: $NAMESPACE${NC}"
    fi
fi

# Determinar qué archivos usar según el namespace
if [[ "$NAMESPACE" == "default" ]]; then
    RBAC_FILE="jenkins-rbac-default.yaml"
    DEPLOYMENT_FILE="jenkins-deployment-default.yaml"
else
    RBAC_FILE="jenkins-rbac.yaml"
    DEPLOYMENT_FILE="jenkins-deployment.yaml"
fi

# Desplegar recursos de Jenkins
echo -e "${YELLOW}Desplegando volumen persistente...${NC}"
kubectl apply -f kubernetes/jenkins-pv.yaml

echo -e "${YELLOW}Desplegando configuración RBAC...${NC}"
kubectl apply -f "kubernetes/$RBAC_FILE"

echo -e "${YELLOW}Desplegando Jenkins...${NC}"
kubectl apply -f "kubernetes/$DEPLOYMENT_FILE"

# Esperar a que Jenkins esté listo
echo -e "${YELLOW}Esperando a que Jenkins esté listo...${NC}"
ready=false
attempts=0
max_attempts=30

while [[ "$ready" == false && $attempts -lt $max_attempts ]]; do
    ((attempts++))
    sleep 10
    
    if [[ "$NAMESPACE" == "default" ]]; then
        pod_status=$(kubectl get pods -l app=jenkins -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    else
        pod_status=$(kubectl get pods -n "$NAMESPACE" -l app=jenkins -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    fi
    
    if [[ $? -eq 0 && "$pod_status" == "Running" ]]; then
        ready=true
        echo -e "${GREEN}Jenkins está listo.${NC}"
    else
        echo -e "${YELLOW}Esperando a que Jenkins esté listo... Intento $attempts de $max_attempts${NC}"
    fi
done

if [[ "$ready" == false ]]; then
    echo -e "${RED}Jenkins no pudo iniciarse después de $max_attempts intentos. Verifica los logs.${NC}"
    exit 1
fi

# Mostrar la URL de acceso
if [[ "$NAMESPACE" == "default" ]]; then
    jenkins_url=$(minikube service jenkins --url)
    echo -e "${GREEN}Jenkins está disponible en: $jenkins_url${NC}"
else
    jenkins_url=$(minikube service jenkins -n "$NAMESPACE" --url)
    echo -e "${GREEN}Jenkins está disponible en: $jenkins_url${NC}"
fi

# Obtener la contraseña inicial
echo -e "\n${YELLOW}Obteniendo contraseña inicial de administrador...${NC}"
if [[ "$NAMESPACE" == "default" ]]; then
    pod_name=$(kubectl get pods -l app=jenkins -o jsonpath='{.items[0].metadata.name}')
else
    pod_name=$(kubectl get pods -n "$NAMESPACE" -l app=jenkins -o jsonpath='{.items[0].metadata.name}')
fi

echo -e "${YELLOW}Esperando a que el archivo de contraseña esté disponible...${NC}"
sleep 30

if [[ "$NAMESPACE" == "default" ]]; then
    initial_password=$(kubectl exec "$pod_name" -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
else
    initial_password=$(kubectl exec -n "$NAMESPACE" "$pod_name" -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
fi

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}Contraseña inicial de administrador:${NC}"
    echo -e "${CYAN}$initial_password${NC}"
else
    echo -e "\n${YELLOW}No se pudo obtener la contraseña inicial automáticamente.${NC}"
    echo -e "${YELLOW}Espera unos minutos más y ejecuta este comando manualmente:${NC}"
    if [[ "$NAMESPACE" == "default" ]]; then
        echo -e "${WHITE}kubectl exec $pod_name -- cat /var/jenkins_home/secrets/initialAdminPassword${NC}"
    else
        echo -e "${WHITE}kubectl exec -n $NAMESPACE $pod_name -- cat /var/jenkins_home/secrets/initialAdminPassword${NC}"
    fi
fi

# Abrir el navegador si se solicitó
if [[ "$OPEN_BROWSER" == true ]]; then
    echo -e "\n${YELLOW}Abriendo Jenkins en el navegador...${NC}"
    if [[ "$NAMESPACE" == "default" ]]; then
        minikube service jenkins --url
    else
        minikube service jenkins -n "$NAMESPACE" --url
    fi
else
    # Mostrar comandos para acceder a Jenkins
    echo -e "\n${YELLOW}Para acceder a Jenkins, ejecuta:${NC}"
    if [[ "$NAMESPACE" == "default" ]]; then
        echo -e "${WHITE}minikube service jenkins${NC}"
    else
        echo -e "${WHITE}minikube service jenkins -n $NAMESPACE${NC}"
    fi
fi

echo -e "\n${CYAN}===== DESPLIEGUE DE JENKINS COMPLETADO =====${NC}"