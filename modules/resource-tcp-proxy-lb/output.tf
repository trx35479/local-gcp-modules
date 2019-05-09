# Expose the load balancer endpoint (ip-address:port)
output "loadbalancer_ip" {
  value = "${google_compute_global_forwarding_rule.loadbalancer.ip_address}"
}

output "loadbalancer_port" {
  value = "${google_compute_global_forwarding_rule.loadbalancer.port_range}"
}
