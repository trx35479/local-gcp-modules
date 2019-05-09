# call load balancer module

data "google_compute_subnetwork" "untrust_subnetwork" {
  project = "${var.host_project_id}"
  name    = "${var.subnetwork}"
  region  = "${var.region}"
}

data "google_compute_subnetwork" "mgmt_subnetwork" {
  project = "${var.host_project_id}"
  name    = "${var.mgmt_subnetwork}"
  region  = "${var.region}"
}

data "google_compute_subnetwork" "palo_subnetwork" {
  project = "${var.host_project_id}"
  name    = "${var.palo_subnetwork}"
  region  = "${var.region}"
}

module "load_balancer" {
  source = "../modules/resource-tcp-proxy-lb"

  name               = "ob"
  service_project_id = "${var.host_project_id}"
  port_name          = "gcp-palo-firewall"
  instance_groups    = ["${google_compute_instance_group.webservers-3.self_link}"]
  ip_address         = "${google_compute_global_address.global-public-ip.address}"
  frontend_port      = "443"
  app_port           = "80"

  #  ssl_secret_crt     = "${var.ssl_secret_crt}"
  #  ssl_secret_key     = "${var.ssl_secret_key}"
}

resource "google_compute_global_address" "global-public-ip" {
  project = "${var.host_project_id}"
  name    = "ip-address"
}

resource "google_compute_instance_group" "webservers-3" {
  project     = "${var.host_project_id}"
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    "${element(google_compute_instance.webservers.*.self_link, 0)}",
    "${element(google_compute_instance.webservers.*.self_link, 1)}",
  ]

  named_port {
    name = "gcp-palo-firewall"
    port = "80"
  }

  zone = "${var.region}-a"
}

resource "google_compute_address" "private5" {
  count        = 2
  name         = "proxy-palo-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.palo_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.palo_subnetwork.self_link}"
}

resource "google_compute_address" "private6" {
  count        = 2
  name         = "proxy-port-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.unstrusted_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.untrust_subnetwork.self_link}"
}

resource "google_compute_address" "private7" {
  count        = 2
  name         = "proxy-port-mgmt-${count.index}"
  address_type = "INTERNAL"
  address      = "${element(var.mgmt_address, count.index)}"
  project      = "${var.host_project_id}"
  subnetwork   = "${data.google_compute_subnetwork.mgmt_subnetwork.self_link}"
}

resource "google_compute_instance" "webservers" {
  project      = "${var.host_project_id}"
  count        = 2
  name         = "instance-${count.index}"
  machine_type = "n1-standard-4"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork    = "${data.google_compute_subnetwork.untrust_subnetwork.self_link}"
    network_ip    = "${element(google_compute_address.private6.*.address, count.index)}"
    access_config = {}
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.palo_subnetwork.self_link}"
    network_ip = "${element(google_compute_address.private5.*.address, count.index)}"
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.mgmt_subnetwork.self_link}"
    network_ip = "${element(google_compute_address.private7.*.address, count.index)}"
  }

  metadata_startup_script = "apt-get install nginx -y"
  tags                    = ["gcp-palo-firewall"]      # this is a critical piece of information as firewall rule uses tag to forward traffic
}

#output "endpoint_ip" {
#  value = "${module.load_balancer.https_lb_ip}"
#}

