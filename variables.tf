variable "location" {
  description = "DC area"
}
variable "vpc_name" {
  description = "Ressource group name"
}

variable "instance_name" {
  description = "Instance name"
}

variable "instance_count" {
  description = "Number of instance"
  default = 1
}

variable "instance_type" {
  description = "The instance type"
}

variable "key_name" {
  description = "The key name to use to connect on server"
}

variable "subnet" {
  description = "The network/subnet where to deploy instance"
}

variable "security_group_names" {
  type = "list"
  description = "The list of security group name to apply on instance"
  default = ["admin"]
}

variable "user_data_path" {
  description = "The cloud-init path"
  default = ""
}

variable "start_ip" {
  description = "The static IP begin range"
}

variable "os_size" {
  description = "The OS size in Go"
  default = 8
}

variable "data_disk_size" {
  description = "The data size disk in Go"
  default = 0
}

variable "tags" {
  type = "map"
}