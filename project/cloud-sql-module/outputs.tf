# Terraform > Outputs
# https://www.terraform.io/docs/configuration/outputs.html

# the instance_address is equivalent to the ip_address
output "instance_ip" {
  value =   var.psc_config.enabled ? null : google_sql_database_instance.db.ip_address[0].ip_address
}

# # the instance_id is equivalent to the connection_name
output "instance_id" {
  value = google_sql_database_instance.db.connection_name
}

# the database server name
output "instance_name" {
  value = var.db_server_name
}

# database name
output "db_name" {
  value = var.db_name
}

# instance service account email address
output "service_account_email_address" {
  value = google_sql_database_instance.db.service_account_email_address
}
