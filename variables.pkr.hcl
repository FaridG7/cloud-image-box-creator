variable "vm_name" {
  type = string
}

variable "cpus" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type    = string
  default = "none"
}

