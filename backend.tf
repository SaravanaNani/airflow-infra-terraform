terraform {
  backend "gcs" {
    bucket = "$BUCKET-NAME"
    prefix = "airflow-gcp/state"
  }
}
