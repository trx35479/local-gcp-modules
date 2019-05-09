output "security_policy_self_link" {
  value = "${google_compute_security_policy.armor.self_link}"
}

output "security_policy_name" {
  value = "${google_compute_security_policy.armor.name}"
}
