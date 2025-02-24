
# Static IP Address for the Load Balancer
resource "google_compute_global_address" "commit_ip" {
  name = "commit-${var.resource_name}-ip"
}

# Backend Service (HTTP) for Cloud Run
resource "google_compute_backend_service" "commit_backend" {
  name     = "commit-${var.resource_name}-backend"
  protocol = "HTTP"

  backend {
    group = google_cloud_run_service.commit_docker_service.id
  }
}

# URL Map (for routing traffic to Cloud Run service)
resource "google_compute_url_map" "commit_url_map" {
  name = "commit-${var.resource_name}-url-map"

  default_service = google_compute_backend_service.commit_backend.id
}

# HTTP Proxy (to handle HTTP requests)
resource "google_compute_target_http_proxy" "commit_http_proxy" {
  name    = "commit-${var.resource_name}-http-proxy"
  url_map = google_compute_url_map.commit_url_map.id
}

# Global Forwarding Rule (to forward traffic to Cloud Run service)
resource "google_compute_global_forwarding_rule" "commit_forwarding_rule" {
  name       = "commit-${var.resource_name}-forwarding-rule"
  ip_address = google_compute_global_address.commit_ip.address
  target     = google_compute_target_http_proxy.commit_http_proxy.id
  port_range = "80"
}
