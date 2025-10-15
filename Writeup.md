# 📘 Airflow Infrastructure – Technical Implementation and Troubleshooting Journal

## 🔍 Objective

To deploy a **self-hosted Apache Airflow environment** on GCP using **Terraform** automation and **metadata-driven startup scripts**, ensuring full integration with Cloud SQL, Secret Manager, and GCS.

---

## 🧱 Phase 1 – Terraform Infrastructure Design

### Components Deployed

* **VPC & Subnet** for internal networking.
* **Firewall Rules** allowing SSH (22), Airflow UI (8080).
* **Service Account** with cloud-platform scope.
* **Cloud SQL Instance (Postgres 14)**.
* **GCS Bucket** for DAGs/logs.
* **Secret Manager** for DB username, password, and SA key.
* **Compute Engine VM** as Airflow host.

**Key Insight:** Modularizing each resource simplified maintenance and reuse.

---

## 🪜 Phase 2 – Provisioner & SSH Failures

Initially, the `remote-exec` and `file` provisioners failed:

```
Error: SSH authentication failed
```

**Root Cause:**
Terraform couldn’t SSH into the VM as metadata-based startup hadn’t yet provisioned SSH keys.

**Fix:**
Removed `remote-exec` and switched to **GCP startup script metadata**.

```hcl
metadata = {
  startup-script = file("${path.module}/startup.sh")
}
```

---

## 🔐 Phase 3 – Secret Manager Integration

Instead of hardcoding credentials, Airflow fetched DB username/password dynamically.

```bash
ACCESS_TOKEN=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token | jq -r .access_token)
DB_PASSWORD=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/db-password/versions/latest:access" | jq -r .payload.data | base64 --decode)
```

---

## 🧩 Phase 4 – Cloud SQL Proxy & Airflow Startup

The proxy container failed initially with `unknown flag '-n'` and `connection refused` errors.

**Fix:** Corrected proxy command:

```yaml
command: ["/cloud_sql_proxy", "-instances=${CLOUDSQL_CONN}=tcp:5432", "-credential_file=/opt/airflow/secrets/sa-key.json"]
```

Also ensured network dependencies were ready before Docker Compose execution by adding:

```bash
until ping -c1 google.com &>/dev/null; do
  echo "Waiting for network..."; sleep 5; done
```

---

## ⚙️ Phase 5 – Permissions & IAM Fixes

Missing roles caused Secret Manager and Cloud SQL access errors. Added:

```hcl
roles = [
  "roles/storage.admin",
  "roles/cloudsql.client",
  "roles/secretmanager.secretAccessor",
  "roles/logging.logWriter"
]
```

---

## 🧰 Phase 6 – Final Validation

Commands used:

```bash
docker ps -a
docker logs airflow-cloudsql-proxy-1
docker logs airflow-airflow-init-1
cat /var/log/startup-script.log
```

**Validation:**

* GCS sync succeeded
* Airflow containers created
* Cloud SQL connection stabilized
* Airflow UI reachable via port 8080

---

## 🚀 Outcome

A **fully automated, metadata-driven Airflow deployment** on GCP using Terraform modules and startup scripts — without any manual SSH or Ansible dependency.

### ✅ Key Features

* Reproducible Terraform automation
* Secret Manager-based dynamic credentials
* No external SSH provisioners
* Modular and reusable architecture
* Production-ready for monitoring and scaling

