
resource "google_secret_manager_secret" "commit-db-secret" {
   provider = google-beta
  secret_id = "commit-db-secret"
  project   = var.project_id
  replication {
    auto {}
  }
}
