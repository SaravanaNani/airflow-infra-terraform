# airflow-infra-terraform


### 🔥 2. HOW TO EXPLAIN THIS PROJECT IN INTERVIEWS (PERFECT ANSWER)


Interview Answer (Strong & Simple)

“I worked on deploying a fully automated Airflow environment on GCP. I created modular Terraform configurations to provision VPC, a Compute Engine VM, Cloud SQL (Postgres), service accounts, firewall rules, and a GCS bucket for DAG storage.

Inside the VM, I used a startup script to install Docker, Cloud SDK, fetch secrets from Secret Manager, and then run Airflow using Docker Compose. The setup included containers for the webserver, scheduler, and Cloud SQL Proxy. I also built a DAG-sync container that continuously syncs DAGs from GCS and uploads logs back to the bucket.

Finally, I configured systemd to ensure Airflow restarts automatically on VM reboot. The entire deployment—from infra to application—was fully automated, secure, and repeatable.”

### 🎯 3. Short 20-second version

“I deployed Airflow on GCP using Terraform and Docker. The VM startup script installed Docker, fetched secrets, synced DAGs from GCS, and ran Airflow with Cloud SQL Proxy. I automated log rotation and made the system persistent with systemd. Everything—from infra to application—was completely automated using Terraform modules.”

### 🧠 4. Resume Version (Copy-Paste)

Apache Airflow Deployment on GCP (Internal Automation Project)

Built Infrastructure using Terraform modules for VPC, service accounts, Cloud SQL, GCS buckets, firewall rules, and Airflow VM.

Automated VM initialization using a startup script that installs Docker, configures Cloud SDK, fetches secrets from Secret Manager, and prepares Airflow directories.

Deployed Airflow using Docker Compose with Cloud SQL Proxy, webserver, scheduler, and an automated DAG-sync container to synchronize GCS DAGs and logs.

Configured log rotation, metadata-based SA key retrieval, and systemd service to ensure Airflow auto-starts after reboots.

Implemented secure credential management through Secret Manager and ensured production-style execution using LocalExecutor and managed Postgres.


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
      │ dag-sync container performs continuous sync│
      └─────────────────────────────────────────────┘
