# define the https proxy global load balancer

resource "random_id" "random_id_certificate" {
  byte_length = 4
  prefix      = "certificate"
}

resource "google_compute_https_health_check" "hc" {
  project             = "${data.google_project.service_project.project_id}"
  name                = "${var.name}-hc"
  request_path        = "/"
  timeout_sec         = 5
  check_interval_sec  = 5
  unhealthy_threshold = 3
  port                = "${var.app_port}"
}

resource "google_compute_ssl_certificate" "certificate" {
  project     = "${data.google_project.service_project.project_id}"
  name        = "${random_id.random_id_certificate.hex}"
  private_key = "${file(var.ssl_secret_key)}"
  certificate = "${file(var.ssl_secret_crt)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "map" {
  project         = "${data.google_project.service_project.project_id}"
  name            = "${var.name}-map"
  default_service = "${google_compute_backend_service.backend.self_link}"
}

resource "google_compute_backend_service" "backend" {
  project   = "${data.google_project.service_project.project_id}"
  name      = "${var.name}-backend-service"
  protocol  = "HTTPS"
  port_name = "${var.port_name}"

  backend {
    group = "${var.instance_groups}"
  }

  health_checks = ["${google_compute_https_health_check.hc.self_link}"]
  security_policy = "${var.security_policy}"
}

resource "google_compute_target_https_proxy" "https" {
  project          = "${data.google_project.service_project.project_id}"
  name             = "${var.name}-target"
  ssl_certificates = ["${google_compute_ssl_certificate.certificate.self_link}"]
  url_map          = "${google_compute_url_map.map.self_link}"
}

resource "google_compute_global_forwarding_rule" "loadbalancer" {
  project    = "${data.google_project.service_project.project_id}"
  name       = "${var.name}-https-lb"
  target     = "${google_compute_target_https_proxy.https.self_link}"
  port_range = "${var.frontend_port}"
  ip_address = "${var.ip_address}"
}
