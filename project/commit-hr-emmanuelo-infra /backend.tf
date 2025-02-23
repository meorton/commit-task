
terraform {
  backend "gcs" {
    bucket = "commit-it-commit-hr-emmanuelo-data-terraform-state"
    prefix = "env/commit-hr-emmanuelo-infra"
  }
}
