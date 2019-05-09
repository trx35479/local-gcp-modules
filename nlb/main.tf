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
  #  source = "../../terraform-gcp-modules/resource-external-tcp-lb"
  #  source = "git@github.com:contino/terraform-gcp-modules.git//resource-external-tcp-lb?ref=e44fb10"
  source = "../modules/resource-network-lb"

  name               = "${var.name}"
  service_project_id = "${var.host_project_id}"
  region             = "${var.region}"
  ip_address         = "${google_compute_address.pub-ip.address}"
  app_port           = "${var.app_port}"
  instances          = ["${google_compute_instance.default.*.self_link}"]
}

resource "google_compute_address" "pub-ip" {
  region  = "${var.region}"
  name    = "${var.name}-ip"
  project = "${var.host_project_id}"
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
  #project = "${var.service_project-id}"

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

#output "endpoint_ip" {
#  value = "${module.glb.loadbalancer_ip}"
#}


#output "endpoint_port" {
#  value = "${module.glb.loadbalancer_port}"
#}

