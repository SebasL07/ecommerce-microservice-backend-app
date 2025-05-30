# Dockerfile for running Postman/Newman E2E tests
FROM node:18-alpine

# Install newman and newman-reporter-htmlextra globally
RUN npm install -g newman newman-reporter-htmlextra

# Create app directory
WORKDIR /e2e

# Copy Postman collection(s) into the container
COPY postman_e2e_test/Ecommerce\ e2e\ test.postman_collection.json collection.json

# Default command (can be overridden)
CMD ["newman", "run", "ollection.json", "--reporters", "cli,htmlextra", "--reporter-htmlextra-export", "newman-report.html"]
