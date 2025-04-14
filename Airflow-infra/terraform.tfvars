project_id             = "adq-get-project"
region                 = "us-central1"
vpc_name               = "airflow-vpc"
subnet_name            = "airflow-subnet"
cidr_block             = "10.10.0.0/16"
sa_name                = "airfloe-sa"
sql_instance_name      = "airflow-db"
sql_tier               = "db-f1-micro"
db_user                = "airflowuser"
db_password            = "StrongPassword123"
db_name                = "airflow"
bucket_name            = "airflow-dags-logs-bucket"
vm_name                = "airflow-prod-vm"
machine_type           = "e2-medium"
zone                   = "us-central1-a"
vm_image               = "ubuntu-os-cloud/ubuntu-2204-lts"
roles = [
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser",
  "roles/storage.objectAdmin",
  "roles/cloudsql.client",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter"
]
