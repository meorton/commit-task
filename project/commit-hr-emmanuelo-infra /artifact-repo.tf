resource "google_artifact_registry_repository" "commit-task" {
  location      = "northamerica-northeast1"
  repository_id = "commit-task"
  description   = "commit-task-images"
  format        = "DOCKER"
  project      = var.project_id
}
