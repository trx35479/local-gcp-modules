# variables for tcp load balancing

variable "service_project_id" {
  description = "The service project that glb resources will be hosted"
}

variable "name" {
  description = "the name of the loadbalancer"
}

variable "port_name" {
  description = "The target named port of instance group"
}

variable "instance_groups" {
  description = "The instance group that will be the target of load balancer, two instance group is currently supported"
  type        = "list"
  default     = ["firewall-group-a", "firewall-group-b"]
}

variable "ip_address" {
  description = "The static public ip, it should be pre-crearted or create before calling the module"
}

variable "frontend_port" {
  description = "The loadbalancer frontend port"
}

variable "app_port" {
  description = "The application port that is running on, it will be used also by the health checks"
}

variable "security_policy" {
  description = "The cloud security policy (defined it with cloud armor)"
  default = ""
}