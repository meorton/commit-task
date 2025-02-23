terraform {
  backend "gcs" {
    bucket = "commit-it-commit-hr-emmanuelo-infra"
    prefix = "env/commit-it-commit-hr-emmanuelo-infra"
  }
}
