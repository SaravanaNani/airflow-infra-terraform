terraform {
  backend "gcs" {
    bucket = "airflow-terraform-state-bucket"
    prefix = "airflow-gcp/state"
  }
}

## gsutil mb -l us-central1 gs://your-terraform-state-bucket/
