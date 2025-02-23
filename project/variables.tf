# Terraform > Variables
# https://www.terraform.io/docs/configuration/variables.html

variable "region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "project_id" {
  type = string

  validation {
    condition     = can(regex("[a-z]+", var.project_id))
    error_message = "ERROR: Project ID must not be empty and needs to be a string."
  }
}

variable "instance_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "custom_db_tier" {
  type    = string
  default = "db-custom-1-3840"
}

variable "db_name" {
  type        = string
  description = "The database name"
  validation {
    condition     = can(regex("[a-z]+", var.db_name))
    error_message = "ERROR: Database name must not be empty and needs to be a string."
  }
}

variable "db_version" {
  type = string
  # available version: 
  # "MYSQL_5_6", "MYSQL_5_7", "MYSQL_8_0",
  # "POSTGRES_9_6", "POSTGRES_11", "POSTGRES_14", "POSTGRES_15",
  # "SQLSERVER_2017_STANDARD"
  validation {
    condition     = contains(["MYSQL_5_6", "MYSQL_5_7", "MYSQL_8_0", "POSTGRES_9_6", "POSTGRES_11", "POSTGRES_13", "POSTGRES_14", "POSTGRES_15", "SQLSERVER_2017_STANDARD", "SQLSERVER_2022_STANDARD"], var.db_version)
    error_message = "ERROR: Database version must be one of the following : MYSQL_5_6, MYSQL_5_7, MYSQL_8_0, POSTGRES_9_6, POSTGRES_11, POSTGRES_13, POSTGRES_14, POSTGRES_15, SQLSERVER_2017_STANDARD, SQLSERVER_2022_STANDARD."
  }
}

variable "db_server_name" {
  type        = string
  description = "The database instance name"
  validation {
    condition     = can(regex("[a-z]+", var.db_server_name))
    error_message = "ERROR: Database instance name must not be empty and needs to be a string."
  }
}

variable "maintenance_window_day" {
  type    = string
  default = "7"
}

variable "maintenance_window_hour" {
  type    = string
  default = "9"
}

variable "backup_start_time" {
  type    = string
  default = "05:00"
}

variable "backup_binary_log_enabled" {
  default = "false"
}

variable "ipv4_enabled" {
  default = "false"
}

variable "private_network" {
  type    = string
  default = ""
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "database_flags" {
  type    = map(any)
  default = {}
}

variable "disk_type" {
  type    = string
  default = "PD_SSD"
}

variable "disk_size" {
  default = null
}

variable "disk_autoresize" {
  default = "true"
}

variable "deletion_protection" {
  default = "true"
}

variable "query_insights_enabled" {
  default = "false"
}

variable "query_string_length" {
  default = null
}

variable "authorized_networks" {
  description = "List of name, public cidr blocks"
  type = list(object({
    name              = string
    public_cidr_block = string
  }))
  default = []
}

variable "backup_location" {
  description = "The location (region) for database backups"
  default     = "northamerica-northeast1"
  validation {
    condition     = contains(["northamerica-northeast1", "northamerica-northeast2"], var.backup_location)
    error_message = "Backup location must be either northamerica-notheast1 or northamerica-northeast2."
  }
}

variable "deletion_policy" {
  default = "DELETE"
}

variable "psc_config" {
  type = object({
    enabled                   = bool
    allowed_consumer_projects = list(string)
  })
  default = {
    enabled                   = false
    allowed_consumer_projects = []
  }
}

variable "edition" {
  type    = string
  default = "ENTERPRISE"
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "Edition must be either ENTERPRISE or ENTERPRISE_PLUS."
  }
}

variable "zone" {
  type        = string
  description = "The zone for the master instance, if not provided a random one will be chosen"
  default     = null
}

variable "secondary_zone" {
  type        = string
  description = "The preferred zone for the secondary/failover instance, it cant be the same as the primary zone"
  default     = null
}

variable "follow_gae_application" {
  type        = string
  description = "A Google App Engine application whose zone to remain in. Must be in the same region as this instance."
  default     = null
}

variable "data_cache_enabled" {
  type        = bool
  description = "Whether data cache is enabled for the instance. Defaults to false. Feature is only available for ENTERPRISE_PLUS tier."
  default     = false
}

variable "ssl_mode" {
  type        = string
  description = "Specify how SSL connection should be enforced in DB connections"
  default     = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
}