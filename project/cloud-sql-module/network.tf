resource "google_compute_network" "commit_network-data" {
  auto_create_subnetworks = false
  project                 = var.project_id
  name                    = "tbm-shopfront-vpc"
}

resource "google_compute_subnetwork" "commit_subnet-data" {
  depends_on = [google_compute_network.commit_network-data]
  project                 = var.project_id
  private_ip_google_access   = true
  name          = "commit_subnet-datawork"
  ip_cidr_range = "100.120.214.0/28"#"100.120.214.24/29"
  region        = "northamerica-northeast1"
  network       = google_compute_network.commit_network-data.id
  secondary_ip_range {
    
    range_name    = "commit_subnet-dataip"
    ip_cidr_range = "10.16.0.0/14"
 }

     secondary_ip_range {
    range_name    = "commit_subnet-datawork-secondaryip"
    ip_cidr_range = "10.32.0.0/16"
     }

  
}
