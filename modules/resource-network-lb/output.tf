# expose network load balancer attributes

output "network-lb-ip" {
  value = "${google_compute_forwarding_rule.loadbalancer.ip_address}"
}
