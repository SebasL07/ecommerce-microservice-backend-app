# Dockerfile para pruebas de carga con Locust
FROM python:3.11-slim

# Instalar dependencias
RUN pip install --no-cache-dir locust

# Copiar archivos de pruebas
WORKDIR /locust
COPY locust.py .

# Comando por defecto (puede ser sobrescrito al ejecutar el contenedor)
ENTRYPOINT ["locust"]
CMD ["--help"]
