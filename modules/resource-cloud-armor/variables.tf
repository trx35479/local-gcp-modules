variable "sec_name" {
  description = "The security policy name that will be assign to the resource"
}

variable "source_ip_ranges" {
  description = "The source IPs that will be allowed to access HTTPs load balancer"
  type = "list"
}

variable "service_project_id" {
  description = "The service project if that cloud armor will be hosted"
}
