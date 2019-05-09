# define the network load balancer

resource "google_compute_http_health_check" "hc" {
  project            = "${var.service_project_id}"
  name               = "${var.name}-hc"
  request_path       = "/"
  check_interval_sec = 5
  port               = "${var.app_port}"
  timeout_sec        = 5
}

resource "google_compute_target_pool" "pool" {
  project = "${var.service_project_id}"
  name    = "${var.name}-target"

  instances = ["${var.instances}"]

  health_checks = ["${google_compute_http_health_check.hc.self_link}"]
}

resource "google_compute_forwarding_rule" "loadbalancer" {
  name       = "${var.name}-nlb"
  region     = "${var.region}"
  project    = "${data.google_project.service_project.project_id}"
  target     = "${google_compute_target_pool.pool.self_link}"
  ip_address = "${var.ip_address}"
}

