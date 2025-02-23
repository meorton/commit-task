#create vpc
resource "google_compute_network" "commit-network-infra" {
  auto_create_subnetworks = false
  project                 = var.project_id
  name                    = "commit-network-infra"
}

#create subnet
resource "google_compute_subnetwork" "commit-subnet-infra" {
  depends_on = [google_compute_network.commit-network-infra]
  project                 = var.project_id
  private_ip_google_access   = true
  name          = "commit-subnet-infrawork"
  ip_cidr_range = "10.0.0.0/16"#"100.120.214.24/29"
  region        = "northamerica-northeast1"
  network       = google_compute_network.commit-network-infra.id
  secondary_ip_range {
    
    range_name    = "commit-subnet-infraip"
    ip_cidr_range = "10.1.0.0/20"
 }

     secondary_ip_range {
    range_name    = "commit-subnet-infrawork-secondaryip"
    ip_cidr_range = "10.2.0.0/20"
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
  network       = google_compute_network.commit-network-infra.self_link 
  project       = var.project_id

  depends_on = [google_project_service.servicenetworking]
}


# Create the VPC peering connection with the Service Networking API
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.commit-network-infra.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]


  depends_on = [google_compute_global_address.private_ip_range]
}



#elastic ip
resource "google_compute_address" "commit-infra-nat-address" {
  project  = var.project_id
  depends_on = [ google_compute_subnetwork.commit-subnet-infra ]
  name   = "commit-infra-nat-manual-ip"
  region = google_compute_subnetwork.commit-subnet-infra.region
}

resource "google_compute_router" "commit-infra-router" {
  depends_on = [ google_compute_network.commit-network-infra ]
  project  = var.project_id
  name    = "commit-infra-nat-router"
  network = google_compute_network.commit-network-infra.name
  region  = "northamerica-northeast1"
}

## Create Nat Gateway

resource "google_compute_router_nat" "commit-infra-nat" {
  depends_on = [ google_compute_address.commit-infra-nat-address ]
  project  = var.project_id
  name                               = "commit-infra-nat"
  router                             = google_compute_router.commit-infra-router.name
  region                             = "northamerica-northeast1"
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.commit-infra-nat-address.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
