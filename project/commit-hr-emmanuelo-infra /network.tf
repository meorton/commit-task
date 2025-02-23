resource "google_compute_network" "commit-network-infra" {
  auto_create_subnetworks = false
  project                 = var.project_id
  name                    = "tbm-shopfront-vpc"
}

resource "google_compute_subnetwork" "commit-subnet-infra" {
  depends_on = [google_compute_network.commit-network-infra]
  project                 = var.project_id
  private_ip_google_access   = true
  name          = "commit-subnet-infrawork"
  ip_cidr_range = "100.120.215.0/28"#"100.120.214.24/29"
  region        = "northamerica-northeast1"
  network       = google_compute_network.commit-network-infra.id
  secondary_ip_range {
    
    range_name    = "commit-subnet-infraip"
    ip_cidr_range = "10.17.0.0/14"
 }

     secondary_ip_range {
    range_name    = "commit-subnet-infrawork-secondaryip"
    ip_cidr_range = "10.33.0.0/16"
     }

  
}

