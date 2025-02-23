resource "google_compute_network" "commit_network" {
  auto_create_subnetworks = false
  project                 = var.project_id
  name                    = "tbm-shopfront-vpc"
}

resource "google_compute_subnetwork" "commit_subnet" {
  depends_on = [google_compute_network.commit_network]
  project                 = var.project_id
  private_ip_google_access   = true
  name          = "commit_subnetwork"
  ip_cidr_range = "100.120.214.0/28"#"100.120.214.24/29"
  region        = "northamerica-northeast1"
  network       = google_compute_network.commit_network.id
  secondary_ip_range {
    
    range_name    = "commit_subnetip"
    ip_cidr_range = "10.16.0.0/14"
 }

     secondary_ip_range {
    range_name    = "commit_subnetwork-secondaryip"
    ip_cidr_range = "10.32.0.0/16"
     }

  
}
