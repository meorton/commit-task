
# Static IP Address for the Load Balancer
resource "google_compute_global_address" "commit_ip" {
  name = "commit-${var.resource_name}-ip"
}




# Health Check for Backend Service (for monitoring health of Cloud Run service)
resource "google_compute_health_check" "commit_health_check" {
  name               = "commit-${var.resource_name}-health-check"
  http_health_check {
    port = 8080
    request_path = "/"
  }
}

# Backend Service for Internal Load Balancer (using Cloud Run)
resource "google_compute_backend_service" "commit_backend" {
  name                  = "commit-${var.resource_name}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL"
  region                = "<REGION>"

  backend {
    group = "https://commit-docker-511112496376.northamerica-northeast1.run.app"
  }

  health_checks = [google_compute_health_check.commit_health_check.id]
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
