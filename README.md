# airflow-infra-terraform

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
