variable "service_project_id" {
  default = "anz-cs-palo-np-88de38"
  description = "The service project that glb resources will be hosted"
}

variable "host_project_id" {
  default = "anz-cs-network-np-a63830"
}

variable "region" {
  default = "australia-southeast1"
}

variable "subnetwork" {
  description = "The subnetwork that the resources will be hosted"
  default     = "anz-cs-palo-np-88de38-unstrusted"
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
  default = ["10.234.0.12", "10.234.0.13"]
}

variable "unstrusted_address" {
  type    = "list"
  default = ["10.255.0.12", "10.255.0.13"]
}

variable "mgmt_address" {
  type    = "list"
  default = ["10.149.2.12", "10.149.2.13"]
}

variable "ssl_secret_crt" {
  default = "~/.ssl/server.crt"
}

variable "ssl_secret_key" {
  default = "~/.ssl/server.key"
}
