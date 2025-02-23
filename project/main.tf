# Terraform > Module
# https://www.terraform.io/docs/modules/index.html

locals {
  zone_lookup_table = {
    "northamerica-northeast1" = ["northamerica-northeast1-a", "northamerica-northeast1-b", "northamerica-northeast1-c"]
    "northamerica-northeast2" = ["northamerica-northeast2-a", "northamerica-northeast2-b", "northamerica-northeast2-c"]
  }
}

locals {
  public          = var.ipv4_enabled == "true" && var.private_network == "" ? "true" : "false"
  disk_autoresize = var.disk_autoresize == "true" && var.disk_size != null ? "false" : "true"
  # for postgres database only. all will have point in time recovery in case of disaster recovery scenario
  point_in_time_recovery = substr(var.db_version, 0, 4) == "POST" ? true : null
  primary_zone           = var.zone == null ? random_shuffle.primary_zone[0].result[0] : var.zone
  // Only provide the secondary zone if the availability type is regional, or the psc_config.enabled is true
  secondary_zone = var.availability_type == "REGIONAL" || var.psc_config.enabled ? var.secondary_zone == null ? random_shuffle.secondary_zone[0].result[0] : var.secondary_zone : null
}

resource "random_shuffle" "primary_zone" {
  count        = var.zone == null ? 1 : 0
  input        = local.zone_lookup_table[var.region]
  result_count = 1
}

resource "random_shuffle" "secondary_zone" {
  count        = var.secondary_zone == null && (var.availability_type == "REGIONAL" || var.psc_config.enabled) ? 1 : 0
  input        = setsubtract(local.zone_lookup_table[var.region], [local.primary_zone])
  result_count = 1
  depends_on   = [random_shuffle.primary_zone]
}

resource "google_sql_database_instance" "db" {
  provider         = google-beta
  project          = var.project_id
  database_version = var.db_version

  name   = var.db_server_name
  region = var.region

  settings {
    tier              = substr(var.db_version, 0, 9) == "SQLSERVER" ? var.custom_db_tier : var.instance_tier
    availability_type = var.availability_type
    disk_autoresize   = local.disk_autoresize
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    edition           = var.edition
    // Prevent the deletion of the instance at the GCP level (API, gcloud, Cloud Console and Terraform)
    deletion_protection_enabled = var.deletion_protection

    insights_config {
      query_insights_enabled = var.query_insights_enabled
      query_string_length    = var.query_string_length
    }

    ip_configuration {
      ipv4_enabled    = local.public
      private_network = var.private_network
      ssl_mode        = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.public_cidr_block
        }
      }

      dynamic "psc_config" {
        for_each = lookup(var.psc_config, "enabled", false) ? [1] : []
        content {
          psc_enabled               = lookup(var.psc_config, "enabled", false)
          allowed_consumer_projects = lookup(var.psc_config, "allowed_consumer_projects", [])
        }
      }
    }

    backup_configuration {
      start_time                     = var.backup_start_time
      enabled                        = true
      binary_log_enabled             = var.backup_binary_log_enabled
      point_in_time_recovery_enabled = local.point_in_time_recovery
      location                       = var.backup_location
    }

    maintenance_window {
      day  = var.maintenance_window_day
      hour = var.maintenance_window_hour
    }

    dynamic "database_flags" {
      iterator = flag
      for_each = var.database_flags

      content {
        name  = flag.key
        value = flag.value
      }
    }

    location_preference {
      zone                   = local.primary_zone
      secondary_zone         = local.secondary_zone
      follow_gae_application = var.follow_gae_application
    }

    dynamic "data_cache_config" {
      for_each = var.edition == "ENTERPRISE_PLUS" && var.data_cache_enabled ? ["cache_enabled"] : []
      content {
        data_cache_enabled = var.data_cache_enabled
      }
    }

  }
  // Prevent destroy of the instance using the Terraform destroy command
  lifecycle {
    ignore_changes = [
      database_version,
      settings[0].database_flags
    ]
  }


}

resource "google_sql_database" "default" {
  name            = var.db_name
  project         = var.project_id
  instance        = google_sql_database_instance.db.name

}

resource "google_sql_ssl_cert" "client_cert" {
  project     = var.project_id
  common_name = "default-client-cert"
  instance    = google_sql_database_instance.db.name
}
