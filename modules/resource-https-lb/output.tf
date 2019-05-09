# expose the ip of the load balancer

output "https_lb_ip" {
  value = "${google_compute_global_forwarding_rule.loadbalancer.ip_address}"
}
