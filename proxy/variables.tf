variable "region" {
  default = "australia-southeast1"
}

variable "name" {
  description = ""
  default     = "google-lb"
}

variable "host_project_id" {
  description = "The host project id"
  default     = "anz-cs-network-np-a63830"
}

variable "service_project_id" {
  description = "The service project id where the resource will be created"
  default     = "anz-cs-palo-np-88de38"
}

variable "subnetwork" {
  description = "The subnetwork that the resources will be hosted"
  default     = "anz-cs-palo-np-88de38-unstrusted"
}

variable "named_port" {
  description = "The named port - it should be noted from the creation of instance_group"
  default     = "palo-port"
}

variable "frontend_port" {
  description = "The frontend port the loadbalancer will listen to"
  default     = "80"
}

variable "app_port" {
  description = "The port where the webservers are listening to"
  default     = "80"
}

variable "mgmt_subnetwork" {
  description = "The management subnetwork"
  default     = "anz-cs-palo-np-88de38-management"
}

variable "palo_subnetwork" {
  description = "palo subnetwork"
  default     = "anz-cs-palo-np-88de38-subnet"
}

variable "palo_address" {
  type    = "list"
  default = ["10.234.0.10", "10.234.0.11"]
}

variable "unstrusted_address" {
  type    = "list"
  default = ["10.255.0.10", "10.255.0.11"]
}

variable "mgmt_address" {
  type    = "list"
  default = ["10.149.2.10", "10.149.2.11"]
}
