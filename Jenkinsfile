pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stage', 'prod'],
            description: 'Selecciona el ambiente de despliegue'
        )
    }

    environment {
        DOCKER_NAMESPACE = "sebasl07"
        K8S_NAMESPACE = "default"
        SELECTED_ENV = "${params.ENVIRONMENT}"
    }

    stages {
        stage('Preparar Entorno') {
            steps {
                sh '''
                echo "================ PREPARAR ENTORNO ================"
                echo "Preparando entorno para: ${SELECTED_ENV}"

                export PATH=$HOME/bin:$PATH

                # Instalar Java 11 para Maven (el proyecto requiere Java 11)
                echo "Instalando Java 11 para Maven..."
                if [ ! -d $HOME/java11 ]; then
                    cd /tmp
                    curl -L -o openjdk-11.tar.gz https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
                    tar -xzf openjdk-11.tar.gz
                    mv jdk-11.0.2 $HOME/java11
                    cd -
                fi

                export JAVA_HOME=$HOME/java11
                export PATH=$HOME/java11/bin:$PATH
                ./mvnw clean package "-DskipTests"
                
                echo "Verificando Java para Maven:"
                java -version
                javac -version

                echo "Verificando Maven..."
                if ! command -v mvn &> /dev/null; then
                    echo "Instalando Maven..."
                    rm -rf $HOME/maven
                    cd /tmp
                    curl -sL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -o apache-maven-3.8.6-bin.tar.gz
                    tar -xzf apache-maven-3.8.6-bin.tar.gz
                    mv apache-maven-3.8.6 $HOME/maven
                    export PATH=$HOME/maven/bin:$PATH
                    echo 'export PATH=$HOME/maven/bin:$PATH' >> ~/.bashrc
                    cd -
                fi
                mvn --version

                # Instalar Node.js y npm si no existen
                echo "Instalando Node.js binario..."
                if ! command -v node &> /dev/null; then
                    rm -rf $HOME/nodejs
                    cd /tmp
                    curl -L -o node-v18.19.0-linux-x64.tar.gz https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.gz
                    tar -xzf node-v18.19.0-linux-x64.tar.gz
                    mv node-v18.19.0-linux-x64 $HOME/nodejs
                    export PATH=$HOME/nodejs/bin:$PATH
                    echo 'export PATH=$HOME/nodejs/bin:$PATH' >> ~/.bashrc
                    cd -
                fi
                node --version
                npm --version

                # Instalar newman globalmente
                echo "Instalando newman..."
                npm install -g newman
                newman --version

                # Instalar Python3 localmente si no está presente
                if ! command -v python3 &> /dev/null; then
                    echo "Python3 no encontrado. Instalando localmente..."
                    cd /tmp
                    curl -O https://www.python.org/ftp/python/3.11.8/Python-3.11.8.tgz
                    tar -xzf Python-3.11.8.tgz
                    cd Python-3.11.8
                    ./configure --prefix=$HOME/python3
                    make -j$(nproc)
                    make install
                    export PATH=$HOME/python3/bin:$PATH
                    echo 'export PATH=$HOME/python3/bin:$PATH' >> ~/.bashrc
                    cd -
                fi

                # Instalar Python3 y Locust solo en stage
                if [ "${SELECTED_ENV}" = "stage" ]; then
                    echo "Verificando e instalando Python para Locust..."
                    if ! command -v python3 &> /dev/null; then
                        echo "ERROR: Python3 no está instalado en el agente Jenkins. Por favor, instala Python3 y pip antes de ejecutar el pipeline."
                        exit 1
                    fi
                    echo "Instalando locust..."
                    python3 -m pip install --user locust --break-system-packages || pip3 install --user locust --break-system-packages
                else
                    echo "Saltando instalación de Locust para ambiente ${SELECTED_ENV}"
                fi

                echo "=== RESUMEN DE HERRAMIENTAS INSTALADAS ==="
                mvn --version
                node --version
                npm --version
                newman --version
                python3 -m locust --version || echo "Locust pendiente de verificar en PATH"
                echo "============================================"
                '''
            }
        }

        stage('Build Maven') {
            when {
                environment name: 'SELECTED_ENV', value: 'dev'
            }
            steps {
                sh '''
                echo "================ BUILD MAVEN ================"
                export PATH=$HOME/bin:$PATH
                export JAVA_HOME=$HOME/java11
                export PATH=$HOME/java11/bin:$PATH
                ./mvnw clean package "-DskipTests"
                '''
            }
        }
        // Pruebas Unitarias solo en Stage
        stage('Unit Tests') {
            when {
                environment name: 'SELECTED_ENV', value: 'stage'
            }
            steps {
                sh '''
                echo "================ UNIT TESTS ================"
                export PATH=$HOME/bin:$PATH
                export JAVA_HOME=$HOME/java11
                export PATH=$HOME/java11/bin:$PATH
                echo "Ejecutando pruebas unitarias en ambiente DEV"
                ./mvnw test
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }
        // Pruebas de Integración solo en stage
        stage('Integration Tests') {
            when {
                environment name: 'SELECTED_ENV', value: 'stage'
            }
            steps {
                sh '''
                echo "================ INTEGRATION TESTS ================"
                export PATH=$HOME/bin:$PATH
                export JAVA_HOME=$HOME/java11
                export PATH=$HOME/java11/bin:$PATH
                echo "Ejecutando pruebas de integración en ambiente DEV"
                ./mvnw verify "-Dspring.profiles.active=test" "-Dtest=none" "-DfailIfNoTests=false" "-DskipTests=true" "-Dit.test=*IT,*Integration*,*IntegrationTest*"
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/failsafe-reports/*.xml'
                }
            }
        }
        // Despliegue en Kubernetes en STAGE y PROD
        stage('Desplegar en Kubernetes') {
            when {
                anyOf {
                    environment name: 'SELECTED_ENV', value: 'prod'
                    environment name: 'SELECTED_ENV', value: 'stage'
                }
            }
            steps {
                sh '''
                echo "================ DESPLEGAR EN KUBERNETES ================"
                echo "Desplegando infraestructura en Kubernetes en ambiente ${SELECTED_ENV}"
                # Desplegar Zipkin
                kubectl apply -f kubernetes/${SELECTED_ENV}/01-zipkin.yaml
                sleep 30
                # Desplegar Service Discovery (Eureka)
                kubectl apply -f kubernetes/${SELECTED_ENV}/02-service-discovery.yaml
                sleep 60
                # Desplegar Cloud Config
                kubectl apply -f kubernetes/${SELECTED_ENV}/03-cloud-config.yaml
                sleep 60
                # Desplegar API Gateway
                kubectl apply -f kubernetes/${SELECTED_ENV}/04-api-gateway.yaml
                sleep 60
                # Desplegar microservicios
                kubectl apply -f kubernetes/${SELECTED_ENV}/05-user-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/06-product-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/07-order-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/08-payment-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/09-shipping-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/10-favourite-service.yaml
                kubectl apply -f kubernetes/${SELECTED_ENV}/11-proxy-client.yaml
                echo "Verificando que todos los pods estén en ejecución"
                kubectl get pods
                '''
            }
        }
        // Verificar Despliegue y port forwarding en STAGE y PROD
        stage('Verificar Despliegue y port forwarding') {
            when {
                anyOf {
                    environment name: 'SELECTED_ENV', value: 'prod'
                    environment name: 'SELECTED_ENV', value: 'stage'
                }
            }
            steps {
                sh '''
                echo "================ VERIFICAR DESPLIEGUE Y PORT FORWARDING ================"
                echo "Verificando el despliegue en ambiente ${SELECTED_ENV}"
                kubectl get pods
                kubectl get services
                echo "Realizando port forwarding para acceder a los servicios"
                kubectl port-forward service/api-gateway 8080:8080 --address
                '''
            }
        }
        // Pruebas E2E con Postman/Newman y de Carga con Locust solo en STAGE
        stage('E2E y Pruebas de Carga') {
            when {
                environment name: 'SELECTED_ENV', value: 'stage'
            }
            steps {
                sh '''
                echo "================ E2E Y PRUEBAS DE CARGA ================"
                echo "Ejecutando pruebas E2E con Postman/Newman en ambiente STAGE"
                cd postman_e2e_test
                docker build -t e2e-tests .
                docker run --network host --rm e2e-tests
                echo "Ejecutando pruebas de carga con Locust en ambiente STAGE"
                cd ../locust
                docker build -t locust-tests .
                docker run --network host --rm locust-tests --host=http://localhost:8080 --headless -u 100 -r 20 -t 30s --csv=load_test_report
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'locust/load_test_report*.csv', allowEmptyArchive: true
                }
            }
        } 
 
    }

    post {
        always {
            echo "Limpiando espacio de trabajo..."
            cleanWs()
        }
        success {
            echo "Pipeline finalizado exitosamente para ${SELECTED_ENV}"
        }
        failure {
            echo "Pipeline falló para ${SELECTED_ENV}"
            echo "Revisa los logs para más detalles."
        }
    }
}
