# define the security policy for https load balancer

resource "google_compute_security_policy" "armor" {
  name = "${var.sec_name}"
  project = "${var.service_project_id}"

  rule {
    action = "deny(403)"

    match {
      "config" {
        src_ip_ranges = ["*"]
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority    = "2147483647"
    description = "Deny all other IPs except the defined source ip ranges"
  }

  rule {
    action = "allow"

    "match" {
      "config" {
        src_ip_ranges = ["${var.source_ip_ranges}"]
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority    = "2001"
    description = "Allow IPs that are defined from source ip ranges"
  }
}
