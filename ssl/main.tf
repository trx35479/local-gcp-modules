module "glb" {
  source = "modules\/resource-tcp-proxy-lb"

  host_project_id = "project1-173203"
  named_port = "${map(google_compute_instance_group.webservers.named_port, 0)}"
  port_name = "palo-port"
  ssl_secret_key = "~/.ssl/server.key"
  ssl_secret_crt = "~/.ssl/server.crt"
  instance_groups = "${google_compute_instance_group.webservers.self_link}"
  ip_address = "${google_compute_global_address.global-public-ip.address}"
  network_name = "default"
  firewall_port = ["1320", "443"]
}

resource "google_compute_global_address" "global-public-ip" {
  name = "global-ip-address"
}

resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    "${google_compute_instance.default.self_link}",
  ]

  named_port {
    name = "palo-port"
    port = "80"
  }

  zone = "australia-southeast1-a"
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = "australia-southeast1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {}
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "apt-get install nginx -y"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
