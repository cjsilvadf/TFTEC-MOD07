variable "ambiente" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "resource_group_location" {
  type = string
}
variable "storage_account_name" {
  type = string
}

variable "storage_share_name" {
  type = string
}

variable "storage_share_quota" {
  type = string
}

variable "storage_share_directory_name" {
  type = string

}
variable "tags" {
  type        = map(any)
  description = "Tags nos Recursos e Serviços do azure"
  default = {
    DataClassification = "General"
    Criticalidade      = "Business unit-critical"
    BusinnessUnit      = "Marketing"
    OpsTeam            = "Cloud operations"

  }
}
#LAB FILE SYNC
variable "rg_name_lab07" {
  type = string
}
variable "location_rg_name_lab07" {
  type        = string
  
}
variable "vnet_name_lab07" {
  type = string
}
variable "subnet_name_lab07" {
  type = string
}
variable "address_vnet" {
  type = list(any)
}
variable "address_prefix_subnets" {
  type = list(any)
}
variable "nsg_name" {
  type = string
}
variable "vm_name" {
  type = string
}

variable "admin_login" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "vmsize_web" {
  type = string
}

variable "storage_sync_name" {
  type = string

}
variable "storage_sync_group" {
  type        = string
  description = "(optional) describe your variable"
}
variable "storage_sync_cloud_endpoint_name" {
  type = string

}