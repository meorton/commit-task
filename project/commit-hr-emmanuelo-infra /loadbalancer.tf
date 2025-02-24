
# Static IP Address for the Load Balancer
resource "google_compute_global_address" "commit_ip" {
 project                 = var.project_id
  name           = "commit-${var.resource_name}-ip"
  address_type   = "EXTERNAL"
}

# Health Check for Backend Service (for monitoring health of Cloud Run service)
resource "google_compute_health_check" "commit_health_check" {
  name               = "commit-${var.resource_name}-health-check"
  project                 = var.project_id
  http_health_check {
    port = 8080
    request_path = "/"
  }
}


resource "google_compute_network_endpoint_group" "commit_neg" {
project                 = var.project_id
network_endpoint_type = "SERVERLESS"
  name                    = "commit-${var.resource_name}-neg"
  network                  = "commit-network-infra"
  subnetwork               = "commit-subnet-infrawork"
  default_port = "8080"
  zone                  = " northamerica-northeast1"

}


resource "google_compute_backend_service" "commit_backend" {
  project               = var.project_id
  name                  = "commit-${var.resource_name}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group                = google_compute_network_endpoint_group.commit_neg.id
    balancing_mode       = "RATE"
    max_rate_per_endpoint = 100  # Adjust this value based on your requirements
  }

  health_checks = [google_compute_health_check.commit_health_check.id]
}

# URL Map (for routing traffic to Cloud Run service)
resource "google_compute_url_map" "commit_url_map" {
 project                 = var.project_id
  name = "commit-${var.resource_name}-url-map"

  default_service = google_compute_backend_service.commit_backend.id
}

# HTTP Proxy (to handle HTTP requests)
resource "google_compute_target_http_proxy" "commit_http_proxy" {
  project                 = var.project_id
  name    = "commit-${var.resource_name}-http-proxy"
  url_map = google_compute_url_map.commit_url_map.id
}

# Global Forwarding Rule (to forward traffic to Cloud Run service)
resource "google_compute_global_forwarding_rule" "commit_forwarding_rule" {
  project                 = var.project_id
  name       = "commit-${var.resource_name}-forwarding-rule"
  ip_address = google_compute_global_address.commit_ip.address
  target     = google_compute_target_http_proxy.commit_http_proxy.id
  port_range = "8080"
}
