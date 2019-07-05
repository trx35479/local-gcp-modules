# call load balancer module

data "google_compute_subnetwork" "untrust_subnetwork" {
  project = "${var.host_project_id}"
  name   = "${var.subnetwork}"
  region = "${var.region}"
}

data "google_compute_subnetwork" "mgmt_subnetwork" {
  project = "${var.host_project_id}"
  name    = "${var.mgmt_subnetwork}"
  region = "${var.region}"
}

data "google_compute_subnetwork" "palo_subnetwork" {
  project = "${var.host_project_id}"
  name    = "${var.palo_subnetwork}"
  region = "${var.region}"
}

module "load_balancer" {
  source = "../modules/resource-https-lb"

  name               = "ob"
  service_project_id = "${var.host_project_id}"
  port_name          = "${var.port_name}"
  instance_groups    = "${google_compute_instance_group.webservers.self_link}"
  ip_address         = "${google_compute_global_address.global-public-ip.address}"
  frontend_port      = "${var.frontend_port}"
  app_port           = "${var.app_port}"
  ssl_secret_crt     = "${var.ssl_secret_crt}"
  ssl_secret_key     = "${var.ssl_secret_key}"
  security_policy    = "${module.cloud_armor.security_policy_name}"
}

module "cloud_armor" {
  source = "../modules/resource-cloud-armor"

  source_ip_ranges = ["130.0.0.0/16", "35.120.0.0/22"]
  sec_name = "google-policy"
  service_project_id = "${var.host_project_id}"
}

resource "google_compute_global_address" "global-public-ip" {
  project = "${var.host_project_id}"
  name = "ip-address"
}

resource "google_compute_instance_group" "webservers" {
  project     = "${var.host_project_id}"
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    "${element(google_compute_instance.default.*.self_link, 0)}",
    "${element(google_compute_instance.default.*.self_link, 1)}",
  ]

  named_port {
    name = "${var.port_name}"
    port = "${var.app_port}"
  }

  zone = "${var.region}-a"
}

resource "google_compute_address" "private1" {
  count        = 2
  name         = "palo-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.palo_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.palo_subnetwork.self_link}"
}

resource "google_compute_address" "private2" {
  count        = 2
  name         = "port-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.unstrusted_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.untrust_subnetwork.self_link}"
}

resource "google_compute_address" "private3" {
  count        = 2
  name         = "port-mgmt-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.mgmt_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.mgmt_subnetwork.self_link}"
}

resource "google_compute_instance" "default" {
  project      = "${var.host_project_id}"
  count        = 2
  name         = "test-${count.index}"
  machine_type = "n1-standard-4"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork    = "${data.google_compute_subnetwork.untrust_subnetwork.self_link}"
    network_ip    = "${element(google_compute_address.private2.*.address, count.index)}"
    access_config = {}
  }
  network_interface {
    subnetwork = "${data.google_compute_subnetwork.palo_subnetwork.self_link}"
    network_ip = "${element(google_compute_address.private1.*.address, count.index)}"
  }
  network_interface {
    subnetwork = "${data.google_compute_subnetwork.mgmt_subnetwork.self_link}"
    network_ip = "${element(google_compute_address.private3.*.address, count.index)}"
  }
  metadata_startup_script = "apt-get install nginx -y"
  tags                    = ["gcp-palo-firewall"]      # this is a critical piece of information as firewall rule uses tag to forward traffic
}

output "endpoint_ip" {
  value = "${module.load_balancer.https_lb_ip}"
}
