# define the tcp proxy for load balancer

resource "google_compute_health_check" "check" {
  project            = "${data.google_project.service_project.project_id}"
  name               = "${var.name}-hc"
  check_interval_sec = 5
  timeout_sec        = 5

  tcp_health_check {
    port = "${var.app_port}"
  }
}

resource "google_compute_backend_service" "backend" {
  name      = "${var.name}-backend"
  project   = "${data.google_project.service_project.project_id}"
  protocol  = "TCP"
  port_name = "${var.port_name}"
  security_policy = "${var.security_policy}"

  backend = [
    {
      group = "${element(var.instance_groups, 0)}"
    },
    {
      group = "${element(var.instance_groups, 1)}"
    },
  ]

  health_checks = ["${google_compute_health_check.check.self_link}"]
}

resource "google_compute_target_tcp_proxy" "proxy" {
  name            = "${var.name}-tcp"
  project         = "${data.google_project.service_project.project_id}"
  backend_service = "${google_compute_backend_service.backend.self_link}"
}

resource "google_compute_global_forwarding_rule" "loadbalancer" {
  name       = "${var.name}-lb"
  project    = "${data.google_project.service_project.project_id}"
  target     = "${google_compute_target_tcp_proxy.proxy.self_link}"
  port_range = "${var.frontend_port}"
  ip_address = "${var.ip_address}"
}