module "cloudsql_commit" {
  depends_on = [google_compute_network.commit-network-infra, google_compute_subnetwork.commit-subnet-infra]
  for_each         = var.cloudsql_instance
  source                  = "git::https://git@github.com/meorton/cloud-sql-module.git?ref=v1.4.0"
  project_id              = var.project_id
  db_server_name          = "test-cloud-sql"
  db_name                 = "test-cloud-sql"
  db_version              = "POSTGRES_14"
  private_network         = google_compute_network.network.self_link 
  region                  = "us-central1"
  backup_start_time       = "06:00"
  maintenance_window_hour = "8"
  maintenance_window_day  = "6"
  #deletion_policy        = "DELETE"
   query_insights_enabled = true
   query_string_length    = "2056"
    database_flags = {
    max_connections         = "2000"
   "cloudsql.enable_pgaudit"  = "on"
    "pgaudit.log"           = "all"
  }
  instance_tier           = each.value.machine_type
  availability_type       = "REGIONAL"

}
