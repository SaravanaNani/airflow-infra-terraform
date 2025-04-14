resource "google_service_account" "sa" {
  account_id   = var.sa_name
  display_name = "Airflow Service Account"
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.sa.email}"
}