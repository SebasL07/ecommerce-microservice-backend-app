$services = @(
    @{Name = "service-discovery"; Port = 8761},
    @{Name = "cloud-config"; Port = 9296},
    @{Name = "api-gateway"; Port = 8080},
    @{Name = "proxy-client"; Port = 8900},
    @{Name = "order-service"; Port = 8300},
    @{Name = "payment-service"; Port = 8400},
    @{Name = "product-service"; Port = 8500},
    @{Name = "shipping-service"; Port = 8600},
    @{Name = "user-service"; Port = 8700},
    @{Name = "favourite-service"; Port = 8800}
)

foreach ($service in $services) {
    $serviceName = $service.Name
    $port = $service.Port
    $dockerfilePath = Join-Path -Path $PSScriptRoot -ChildPath "$serviceName\Dockerfile"
    
    if (Test-Path $dockerfilePath) {
        $serviceJar = "$serviceName.jar"
        
        # Crear el contenido del Dockerfile
        $dockerfileContent = @"
FROM openjdk:11
ARG PROJECT_VERSION=0.1.0
RUN mkdir -p /home/app
WORKDIR /home/app
ENV SPRING_PROFILES_ACTIVE dev
COPY . ./
ADD target/$serviceName-v`${PROJECT_VERSION}.jar $serviceJar
EXPOSE $port
ENTRYPOINT ["java", "-Dspring.profiles.active=`${SPRING_PROFILES_ACTIVE}", "-jar", "$serviceJar"]
"@
        
        # Escribir el contenido en el archivo
        Set-Content -Path $dockerfilePath -Value $dockerfileContent
        
        Write-Host "Updated Dockerfile for $serviceName with port $port"
    } else {
        Write-Host "Dockerfile not found for $serviceName"
    }
}
