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
                ./mvnw clean package -DskipTests
                
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

                '''
            }
        }

        stage('Build Maven') {
            steps {
                sh '''

                export PATH=$HOME/bin:$PATH
                
                export JAVA_HOME=$HOME/java11
                export PATH=$HOME/java11/bin:$PATH
                ./mvnw clean package -DskipTests
                
                echo "Verificando Java para Maven:"
                java -version
                javac -version

                ./mvnw clean package -DskipTests
                '''
            }
        }

        // Pruebas Unitarias y de Integración solo en DEV
        stage('Unit and Integration Tests') {
            when {
                environment name: 'SELECTED_ENV', value: 'dev'
            }
            steps {
                sh '''
                echo "Ejecutando pruebas unitarias y de integración en ambiente DEV"
                ./mvnw clean verify -DskipTests=false
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                    docker-compose -f compose.yml build
                    docker-compose -f compose.yml push
                    docker logout
                    '''
                }
            }
        }

        // Pruebas E2E con Postman/Newman y de Carga con Locust solo en STAGE
        stage('E2E y Pruebas de Carga') {
            when {
                environment name: 'SELECTED_ENV', value: 'stage'
            }
            steps {
                sh '''
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

        // Despliegue en Kubernetes solo en PROD
        stage('Desplegar en Kubernetes') {
            when {
                environment name: 'SELECTED_ENV', value: 'prod'
            }
            steps {
                sh '''
                echo "Desplegando infraestructura en Kubernetes en ambiente PROD"
                
                # Desplegar Zipkin
                kubectl apply -f kubernetes/prod/01-zipkin.yaml
                sleep 30
                
                # Desplegar Service Discovery (Eureka)
                kubectl apply -f kubernetes/prod/02-service-discovery.yaml
                sleep 60
                
                # Desplegar Cloud Config
                kubectl apply -f kubernetes/prod/03-cloud-config.yaml
                sleep 60
                
                # Desplegar API Gateway
                kubectl apply -f kubernetes/prod/04-api-gateway.yaml
                sleep 60
                
                # Desplegar microservicios
                kubectl apply -f kubernetes/prod/05-user-service.yaml
                kubectl apply -f kubernetes/prod/06-product-service.yaml
                kubectl apply -f kubernetes/prod/07-order-service.yaml
                kubectl apply -f kubernetes/prod/08-payment-service.yaml
                kubectl apply -f kubernetes/prod/09-shipping-service.yaml
                kubectl apply -f kubernetes/prod/10-favourite-service.yaml
                kubectl apply -f kubernetes/prod/11-proxy-client.yaml
                
                echo "Verificando que todos los pods estén en ejecución"
                kubectl get pods
                '''
            }
        }

        stage('Verificar Despliegue') {
            when {
                environment name: 'SELECTED_ENV', value: 'prod'
            }
            steps {
                sh '''
                echo "Verificando el despliegue en ambiente PROD"
                kubectl get services
                kubectl get pods
                '''
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
