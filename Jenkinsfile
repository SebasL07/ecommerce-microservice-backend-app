pipeline {
    agent any
    
    environment {
        DOCKER_NAMESPACE = "kenbra"
        K8S_NAMESPACE = "default"
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stage', 'prod'],
            description: 'Selecciona el ambiente de despliegue'
        )
    }

    stages {
        stage('Preparar Entorno') {
            steps {
                sh '''
                echo "Preparando entorno para: ${params.ENVIRONMENT}"
                export PATH=$HOME/bin:$PATH
                java -version || true
                mvn --version || true
                node --version || true
                npm --version || true
                '''
            }
        }

        stage('Build Maven') {
            steps {
                sh '''
                ./mvnw clean package -DskipTests
                '''
            }
        }

        stage('Unit and Integration Tests') {
            steps {
                sh '''
                ./mvnw clean verify -DskipTests=false
                '''
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

        stage('Desplegar Infraestructura y Microservicios') {
            steps {
                sh '''
                echo "Desplegando infraestructura y microservicios en Kubernetes..."
                # Aquí puedes agregar comandos kubectl o scripts de despliegue
                '''
            }
        }

        stage('E2E y Carga (Opcional)') {
            when {
                anyOf {
                    environment name: 'ENVIRONMENT', value: 'stage'
                    environment name: 'ENVIRONMENT', value: 'prod'
                }
            }
            steps {
                sh '''
                echo "Ejecutando pruebas E2E y/o de carga si corresponde..."
                # Aquí puedes agregar comandos para newman o locust
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
            echo "Pipeline finalizado exitosamente para ${params.ENVIRONMENT}"
        }
        failure {
            echo "Pipeline falló para ${params.ENVIRONMENT}"
        }
    }
}
