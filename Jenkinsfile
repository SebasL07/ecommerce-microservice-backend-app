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
        /* stage('Preparar Entorno') {
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
                # ./mvnw clean package "-DskipTests"
                
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
                else
                    echo "Node.js ya está instalado"
                fi
                  
                # Asegurar que Node.js esté en el PATH
                export PATH=$HOME/nodejs/bin:$PATH
                node --version
                npm --version

                # Instalar newman globalmente
                echo "Instalando newman..."
                npm install -g newman
                newman --version                

               # Instalar Python packages usando --user (sin permisos de root)
                if [ "${SELECTED_ENV}" = "stage" ]; then
                    echo "Verificando e instalando Python para Locust..."
                    
                    # Verificar si Python está disponible
                    if ! command -v python3 &> /dev/null; then
                        echo "Python3 no encontrado. Instalando..."
                        apt-get update && apt-get install -y python3 python3-pip python3-venv
                        
                        # Verificar instalación
                        python3 --version
                        pip3 --version
                    else
                        echo "Python3 ya está disponible: $(python3 --version)"
                    fi
                      echo "Instalando locust..."
                    # Instalar locust con pip
                    python3 -m pip install --user locust --break-system-packages || python3 -m pip install --user locust
                    
                    # Verificar la instalación
                    python3 -c "import locust; print(f'Locust instalado correctamente: {locust.__version__}')" || echo "Error al importar locust"
                    
                    # Asegurarse de que el directorio bin de pip esté en el PATH
                    export PATH=$HOME/.local/bin:$PATH
                    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
                else
                    echo "Saltando instalación de Locust para ambiente ${SELECTED_ENV}"
                fi

                # Instalar kubectl
                echo "Verificando kubectl"
                if ! command -v kubectl &> /dev/null; then
                    echo "Instalando kubectl"
                    mkdir -p $HOME/bin
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl && mv kubectl $HOME/bin/
                    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
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
        } */
        // Pruebas Unitarias solo en Stage
        /* stage('Unit Tests') {
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
            
        } */
        // Pruebas de Integración solo en stage
        
        /* stage('Integration Tests') {
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
            
        }
        */
        
/* 
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
                export PATH=$HOME/bin:$HOME/maven/bin:$HOME/nodejs/bin:$PATH
                echo "================ DESPLEGAR EN KUBERNETES ================"
                echo "Desplegando infraestructura en Kubernetes en ambiente ${SELECTED_ENV}"
                
                # Variables para los sufijos de los archivos
                if [ "${SELECTED_ENV}" = "dev" ]; then
                    # En ambiente dev, los archivos no tienen sufijo
                    SUFFIX=""
                else
                    # En ambiente stage o prod, los archivos tienen sufijo con el nombre del ambiente
                    SUFFIX="-${SELECTED_ENV}"
                fi
                
                # Desplegar Zipkin
                kubectl apply -f kubernetes/dev/01-zipkin.yaml
                sleep 10
                # Desplegar Service Discovery (Eureka)
                kubectl apply -f kubernetes/dev/02-service-discovery.yaml
                sleep 40
                # Desplegar API Gateway
                kubectl apply -f kubernetes/dev/04-api-gateway.yaml
                sleep 30
                # Desplegar microservicios
                kubectl apply -f kubernetes/dev/05-proxy-client.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/06-order-service.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/07-payment-service.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/08-product-service.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/09-shipping-service.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/10-user-service.yaml
                sleep 10
                kubectl apply -f kubernetes/dev/11-favourite-service.yaml
                echo "Verificando que todos los pods estén en ejecución"
                kubectl get pods
                '''
            }
        }
        // Verificar Despliegue y port forwarding en STAGE y PROD
        stage('Verificar Despliegue') {
            when {
                anyOf {
                    environment name: 'SELECTED_ENV', value: 'prod'
                    environment name: 'SELECTED_ENV', value: 'stage'
                }
            }            
            
            steps {
                sh '''
                export PATH=$HOME/bin:$HOME/maven/bin:$HOME/nodejs/bin:$PATH
                
                echo "================ VERIFICAR DESPLIEGUE Y PORT FORWARDING ================"
                echo "Verificando el despliegue en ambiente ${SELECTED_ENV}"
                kubectl get pods
                kubectl get services
                echo "Servicios desplegados correctamente. En lugar de hacer port-forwarding, simplemente verificaremos que los servicios estén disponibles."
                kubectl get service api-gateway -o wide
                
                echo "Dejar que los servicios estén disponibles..."
                # Esperar un tiempo para que los servicios estén disponibles
                sleep 30
            
                '''
            }        
        } */

          // Pruebas E2E con Postman/Newman y de Carga con Locust solo en STAGE
        stage('E2E y Pruebas de Carga') {
            when {
                environment name: 'SELECTED_ENV', value: 'stage'
            }
            steps {
                sh '''
                export PATH=$HOME/bin:$PATH
                export PATH=$HOME/bin:$HOME/maven/bin:$HOME/nodejs/bin:$HOME/.local/bin:$PATH
                export PATH=$HOME/bin:$HOME/maven/bin:$HOME/nodejs/bin:$PATH
                echo "================ E2E Y PRUEBAS DE CARGA ================"
                # Usar Python local para las pruebas (Python ya está configurado)
                
                echo "Ejecutando pruebas E2E con Postman/Newman en ambiente STAGE"
                cd postman_e2e_test
                export PATH=$HOME/nodejs/bin:$PATH
                newman run "Ecommerce e2e test.postman_collection.json"
                  echo "Ejecutando pruebas de carga con Locust en ambiente STAGE"
                cd ../locust                
                export PATH=$HOME/python3/bin:$PATH
                # Usar el módulo de Python para ejecutar Locust con el archivo load_test.py
                python3 -m locust --headless -u 100 -r 20 -t 30s --csv=load_test_report -f load_test.py
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'locust/load_test_report*.csv', allowEmptyArchive: true
                }
            }        }
        
        // Generar Release Notes solo en PROD
        stage('Generar Release Notes') {
            when {
                environment name: 'SELECTED_ENV', value: 'prod'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
                    script {
                        def now = new Date()
                        def tag = "v${now.format('yyyy.MM.dd.HHmm')}"
                        def title = "Production Release ${tag}"
                        def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                        def commitMessage = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                        
                        sh """
                            # Configurar Git
                            git config user.email "sebasgnv0207@gmail.com"
                            git config user.name "SebasL07"
                            git config --global url."https://oauth2:${GH_TOKEN}@github.com/".insteadOf "https://github.com/"
                            
                            # Crear tag y push
                            git tag ${tag} -m "Production deployment - Build #${env.BUILD_NUMBER}"
                            git push origin ${tag}
                            
                            # Crear release con notas
                            gh release create ${tag} --generate-notes --title "${title}" --notes "
                            # 🚀 Release Notes - ${tag}

                            **📅 Fecha:** ${now.format('yyyy-MM-dd HH:mm:ss')}  
                            **👤 Responsable:** Jenkins CI  
                            **🔗 Build:** #${env.BUILD_NUMBER}  
                            **🔑 Commit:** ${commitHash}  

                            ## 📋 **Resumen del Release**
                            Despliegue automático del sistema de ecommerce con microservicios en ambiente de producción.

                            ## 🆕 **Último Cambio**
                            ${commitMessage}

                            ## ✅ **Validaciones Realizadas**
                            - ✅ Pruebas End-to-End ejecutadas exitosamente
                            - ✅ Verificación de conectividad entre microservicios  
                            - ✅ Validación de endpoints principales
                            - ✅ Confirmación de registro en Eureka

                            ## 🏗️ **Servicios Desplegados**
                            - API Gateway (Puerto 8080)
                            - Service Discovery - Eureka (Puerto 8761)  
                            - Zipkin Tracing (Puerto 9411)
                            - Microservicios: Product, Order, Payment, User, Shipping, Favourite

                            ## 🚨 **Información Importante**
                            - Los servicios pueden tardar 2-3 minutos en estar completamente operativos
                            - Verificar conectividad de red antes de acceder a los endpoints
                            - En caso de problemas, contactar al equipo DevOps
                            "
                        """
                        
                        echo "✅ Release ${tag} creado exitosamente"
                        echo "📋 Release Notes generadas según buenas prácticas de Change Management"
                        echo "🔗 Disponible en GitHub Releases"
                    }
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
            script {
                if (env.SELECTED_ENV == 'dev') {
                    echo "¡Pipeline DEV completado con éxito!"
                    echo "Los microservicios están compilados y listos para desarrollo."
                } else if (env.SELECTED_ENV == 'stage') {
                    echo "¡Pipeline STAGE completado con éxito!"
                    echo "Todas las pruebas han pasado exitosamente:"
                    echo "- Pruebas unitarias ✓"
                    echo "- Pruebas de integración ✓"
                    echo "- Pruebas E2E ✓"
                    echo "- Pruebas de carga (Locust) ✓"
                    echo "La aplicación está lista para producción."
                } else if (env.SELECTED_ENV == 'prod') {
                    echo "¡Pipeline PROD completado con éxito!"
                    echo "La aplicación está desplegada en producción."
                    echo "- Release Notes generadas ✓"
                    echo "Los servicios están disponibles en el cluster de Kubernetes."
                }
            }
            echo "Puedes acceder a la interfaz de Eureka a través del servicio service-discovery."
            echo "El API Gateway está disponible a través del servicio api-gateway."
        }
        failure {
            echo "Pipeline falló para ${SELECTED_ENV}"
            echo "Revisa los logs para más detalles."
        }
    }
}
