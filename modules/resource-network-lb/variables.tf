# variables for tcp load balancing

variable "service_project_id" {
  description = "The service project that glb resources will be hosted"
}

variable "name" {
  description = "the name of the loadbalancer"
}

variable "ip_address" {
  description = "The static public ip, it should be pre-crearted or create before calling the module"
}

variable "app_port" {
  description = "The application port that is running on, it will be used also by the health checks"
}

variable "instances" {
  description = "Instances for the pool to consume"
  type        = "list"
}

variable "region" {
  default = "Region"
}
