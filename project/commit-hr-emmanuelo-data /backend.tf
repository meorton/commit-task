terraform {
  backend "gcs" {
    bucket = "commit-it-commit-hr-emmanuelo-infra-terraform-state"
    prefix = "env/commit-it-commit-hr-emmanuelo-infra"
  }
}
