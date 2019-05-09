variable "name" {
  description = "The name prefix that will be used on the resources"
}

variable "service_project_id" {
  description = "The service project id to be used"
}

variable "port_name" {
  description = "The named port used by instance group - this is defined as an attribute in instance group"
}

variable "instance_groups" {
  description = "The instance groups that will be attached to the https backend"
}

variable "app_port" {
  description = "The application tcp port"
}

variable "frontend_port" {
  description = "The port https load balancer will listen"
}

variable "ip_address" {
  description = "The global IP address that will be attached to global load balancer"
}

variable "ssl_secret_key" {
  description = "The signed certificate secret key"
}

variable "ssl_secret_crt" {
  description = "The signed certificate secret crt"
}

variable "security_policy" {
  description = "The cloud armor infront of the backend"
  default = ""
}