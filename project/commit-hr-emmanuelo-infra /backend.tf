
terraform {
  required_version = ">= 0.14.9" 
  backend "gcs" {
    bucket = "commit-it-commit-hr-emmanuelo-infra-terraform-state"
    prefix = "env/commit-hr-emmanuelo-infra"
  }
}
