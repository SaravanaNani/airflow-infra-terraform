# 🚀 Apache Airflow on GCP using Terraform & Docker

This project demonstrates a **production-style Apache Airflow deployment on Google Cloud Platform (GCP)** using **Terraform for infrastructure provisioning** and a **startup script for automated configuration and deployment**.

---

## 📌 Architecture Overview

- Infrastructure provisioned using Terraform
- GCE VM initialized via startup script
- Airflow deployed using Docker Compose
- Cloud SQL used as backend database
- GCS used for DAG and log storage
- Secret Manager used for secure credential management

---

## 🏗️ Architecture Flow



                 ┌────────────────────┐
                 │    Terraform       │
                 │  (Infra Modules)   │
                 └─────────┬──────────┘
                           ▼
        ┌────────────────────────────────────────┐
        │           GCP Infrastructure           │
        │ VPC │ Firewall │ GCE VM │ Cloud SQL    │
        │ GCS Bucket │ Service Accounts          │
        └─────────┬──────────────────────────────┘
                   ▼
         ┌──────────────────────────────────┐
         │  GCE VM Startup Script           │
         │ • Install Docker                 │
         │ • Install Cloud SDK              │
         │ • Fetch Secrets from SM          │
         │ • Create Airflow dirs            │
         └─────────┬────────────────────────┘
                   ▼
       ┌────────────────────────────────────────┐
       │         Docker Compose Stack           │
       │  cloud-sql-proxy │ airflow-init        │
       │  webserver │ scheduler │ dag-sync      │
       └─────────┬─────────────────────────────┘
                 ▼
      ┌─────────────────────────────────────────────┐
      │        GCS Bucket (DAGs + Logs)             │
      │ dag-sync container performs continuous sync │
      └─────────────────────────────────────────────┘

---
## ⚙️ Infrastructure Components

- **GCE VM (Ubuntu 22.04)**
- **Cloud SQL (PostgreSQL)**
- **GCS Bucket (DAGs & Logs)**
- **VPC & Firewall Rules**
- **Service Accounts**
- **Secret Manager**

---

## 🔧 Startup Script Responsibilities

The startup script fully automates VM configuration and Airflow deployment.

---

### 1️⃣ System Initialization

- Waits for network readiness
- Updates system packages
- Installs required dependencies

---

### 2️⃣ Docker & Cloud SDK Setup

- Installs Docker Engine and Docker Compose
- Enables and starts Docker service
- Installs Google Cloud SDK for GCP integration

---

### 3️⃣ Metadata & Configuration Fetching

Fetches runtime configuration from GCE metadata:

- Service Account Name
- Cloud SQL Connection Name
- GCS Bucket Name
- Secret IDs (DB credentials & SA key)

---

### 4️⃣ Secure Secret Management

- Retrieves secrets from **GCP Secret Manager**
  - DB Username
  - DB Password
  - Service Account Key
- Stores securely in `/opt/airflow/secrets`

---

### 5️⃣ Directory Setup

Creates required Airflow directories:
    
    /opt/airflow/dags
    /opt/airflow/logs
    /opt/airflow/secrets
 
Sets proper ownership for Airflow execution.

---

### 6️⃣ Log Management

- Configures **logrotate**
- Retains logs for 7 days
- Compresses old logs
- Prevents disk overflow

---

### 7️⃣ GCS Integration

- Bootstraps GCS bucket structure
- Syncs DAGs from GCS → VM
- Continuously syncs:
  - DAGs (GCS → VM)
  - Logs (VM → GCS)

---

### 8️⃣ Docker Compose Deployment

Deploys Airflow stack:

#### Services:

- **cloud-sql-proxy**
  - Connects VM to Cloud SQL securely

- **airflow-init**
  - Initializes DB
  - Creates admin user

- **webserver**
  - Airflow UI (port 8080)

- **scheduler**
  - Executes DAGs

- **dag-sync**
  - Syncs DAGs and logs continuously with GCS

---

### 9️⃣ Airflow Configuration

- Executor: **LocalExecutor**
- Database: **Cloud SQL (PostgreSQL)**
- Credentials: Pulled dynamically from Secret Manager

---

### 🔁 DAG & Log Sync Mechanism

- Runs every 60 seconds
- Uses `gsutil rsync`
- Ensures:
  - Centralized DAG management
  - Persistent logs in GCS

---

### 🔄 Service Reliability (systemd)

Creates a systemd service:

- Auto-starts Airflow after reboot
- Ensures service persistence
- Uses Docker Compose lifecycle

---
---
## 🚀 How to Run This Project

### 1️⃣ Clone Repository

```bash
git clone https://github.com/SaravanaNani/Airflow-GCP-Terraform-Infra.git
cd airflow-gcp-terraform-infra
```
### 2️⃣ Initialize Terraform 

``terraform init``

3️⃣ Validate Configuration (Optional but Recommended)
```
terraform validate
terraform fmt
```

4️⃣ Plan Infrastructure

```terraform plan```
5️⃣ Apply Infrastructure

``` terraform apply -auto-approve ```

👉 This will:

Provision GCP infrastructure
Create GCE VM
Execute startup script automatically
Deploy Airflow using Docker Compose

6️⃣ 🌐 Access Airflow UI

``` http://<VM-PUBLIC-IP>:8080 ```

Default Credentials:

    Username: admin
    Password: admin
    
7️⃣ Destroy Infrastructure (Cleanup)

``` terraform destroy -auto-approve ```

---

## 🔐 Security Highlights

- No hardcoded secrets
- Uses **GCP Secret Manager**
- Service account-based authentication
- Secure Cloud SQL connectivity via proxy

---

## 📈 Key Features

- Fully automated VM bootstrap
- Infrastructure + application setup in one flow
- Secure secret handling
- Continuous DAG synchronization
- Production-style Airflow deployment
- Auto-restart using systemd

---

## 🧠 Learnings

- GCP metadata-driven configuration
- Secret Manager integration
- Docker-based Airflow deployment
- Infrastructure automation best practices
- Handling log rotation and persistence

---

## 🚀 Future Improvements

- Add CI/CD pipeline (GitHub Actions / GitLab CI)
- Add monitoring (Prometheus + Grafana)
- Implement Helm-based Kubernetes deployment
- Enable HTTPS & domain mapping


## 👨‍💻 Author
Saravana L   
