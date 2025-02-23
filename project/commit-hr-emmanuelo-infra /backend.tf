
terraform {
  backend "gcs" {
    bucket = "commit-it-commit-hr-emmanuelo-data"
    prefix = "env/commit-hr-emmanuelo-data"
  }
}
