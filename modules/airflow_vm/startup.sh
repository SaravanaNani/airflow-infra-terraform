#!/bin/bash

echo "Starting Airflow startup script..."

# Wait for network connectivity
echo "Waiting for network..."
until ping -c 1 google.com &> /dev/null; do
  sleep 2
done
echo "Network connected."

# Install prerequisites
sudo apt-get clean
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Google Cloud SDK
echo "Installing Google Cloud SDK..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
sudo apt-get update -y
sudo apt-get install -y google-cloud-sdk

# Fetch metadata attributes
echo "Fetching metadata attributes..."
METADATA_URL="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
SA_NAME=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/sa-name)
CLOUDSQL_CONN_NAME=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/cloudsql-connection-name)
GCS_BUCKET=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/gcs-bucket)
DB_USERNAME_SECRET_ID=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/db_username_secret_id)
DB_PASSWORD_SECRET_ID=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/db_password_secret_id)

export SA_KEY_SECRET_ID=$(curl -s -H "Metadata-Flavor: Google" ${METADATA_URL}/sa_key_secret_id)
echo "Resolved SA_KEY_SECRET_ID=$SA_KEY_SECRET_ID"

PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
echo "Project ID: $PROJECT_ID"

# Set gcloud project
gcloud config set project "$PROJECT_ID"

# Obtain DB credentials from Secret Manager
echo "Fetching DB credentials from Secret Manager..."
DB_USERNAME=$(gcloud secrets versions access latest --secret="$DB_USERNAME_SECRET_ID")
DB_PASSWORD=$(gcloud secrets versions access latest --secret="$DB_PASSWORD_SECRET_ID")

# Create necessary directories
echo "Creating Airflow directories..."
mkdir -p /opt/airflow/logs /opt/airflow/dags /opt/airflow/secrets
chown -R 50000:50000 /opt/airflow

# Fetch service account key
echo "Fetching service account key..."
gcloud secrets versions access latest --secret="$SA_KEY_SECRET_ID" | base64 -d > /opt/airflow/secrets/sa-key.json
chown 50000:50000 /opt/airflow/secrets/sa-key.json
# Write docker-compose.yaml
echo "Creating docker-compose.yaml..."
cat > /opt/airflow/docker-compose.yaml <<EOF
version: '3.8'
services:

  cloud-sql-proxy:
    image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.15.2
    command: >
      /cloud_sql_proxy
      --address 0.0.0.0
      --credentials-file /opt/airflow/secrets/sa-key.json
      ${CLOUDSQL_CONN_NAME}
    volumes:
      - /opt/airflow/secrets/sa-key.json:/opt/airflow/secrets/sa-key.json:ro
    expose:
      - 5432
  webserver:
    image: apache/airflow:2.6.3
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${DB_USERNAME}:${DB_PASSWORD}@cloud-sql-proxy:5432/airflow
    ports:
      - 8080:8080
    volumes:
      - /opt/airflow/dags:/opt/airflow/dags
      - /opt/airflow/logs:/opt/airflow/logs
      - /opt/airflow/secrets/sa-key.json:/opt/airflow/secrets/sa-key.json:ro
    depends_on:
      - cloud-sql-proxy

  scheduler:
    image: apache/airflow:2.6.3
    command: scheduler
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${DB_USERNAME}:${DB_PASSWORD}@cloud-sql-proxy:5432/airflow
    volumes:
      - /opt/airflow/dags:/opt/airflow/dags
      - /opt/airflow/logs:/opt/airflow/logs
      - /opt/airflow/secrets/sa-key.json:/opt/airflow/secrets/sa-key.json:ro
    depends_on:
      - cloud-sql-proxy
EOF

# Start Airflow services
echo "Starting Airflow services..."
cd /opt/airflow
docker compose up -d

# Wait for Cloud SQL Proxy to be up
echo "Waiting for Cloud SQL Proxy to start..."
while ! docker ps | grep -q 'cloud-sql-proxy'; do
  sleep 2
done
echo "Cloud SQL Proxy is running."

# Wait for Airflow Webserver to be healthy
echo "Waiting for Airflow Webserver to be ready..."
until curl --silent --output /dev/null --head --fail http://localhost:8080/health; do
  sleep 5
done
echo "Airflow is up and running."

# Optional: Create an Airflow admin user
# docker compose exec webserver airflow users create \
#   --username admin \
#   --password admin \
#   --firstname Airflow \
#   --lastname Admin \
#   --role Admin \
#   --email admin@example.com
