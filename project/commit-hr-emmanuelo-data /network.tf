#create vpc
resource "google_compute_network" "commit-network-data" {
  auto_create_subnetworks = false
  project                 = var.project_id
  name                    = "commit-network-data"
}

#create subnet
resource "google_compute_subnetwork" "commit-subnet-data" {
  depends_on = [google_compute_network.commit-network-data]
  project                 = var.project_id
  private_ip_google_access   = true
  name          = "commit-subnet-datawork"
  ip_cidr_range = "100.120.214.0/28"#"100.120.214.24/29"
  region        = "northamerica-northeast1"
  network       = google_compute_network.commit-network-data.id
  secondary_ip_range {
    
    range_name    = "commit-subnet-dataip"
    ip_cidr_range = "10.16.0.0/14"
 }

     secondary_ip_range {
    range_name    = "commit-subnet-datawork-secondaryip"
    ip_cidr_range = "10.32.0.0/16"
     }

  
}


# Enable the Service Networking API
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  project = var.project_id
}

# Reserve a global internal IP range for Private Services Access
resource "google_compute_global_address" "private_ip_range" {
  name          = "private-services-${var.project_id}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.commit-network-data.self_link 
  project       = var.project_id

  depends_on = [google_project_service.servicenetworking]
}


# Create the VPC peering connection with the Service Networking API
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.commit-network-data.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [google_compute_global_address.private_ip_range]
}
