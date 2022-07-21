#
# Variables with default values, alter according to the your environment.
#
variable "data_center" {
  default = "ha-datacenter"
}

variable "data_store" {
  default = "ds_012"
}

variable "mgmt_lan" {
  default = "VM Network"
}

variable "net_adapter_type" {
  default = "vmxnet3"
}

variable "guest_id" {
  default = "debian10_64Guest"
  description = "Provide the guest ID Ex. debian10_64Guest"
}

variable "custom_iso_path" {
  description = "Input a iso path for a VM Ex. iso/centos7-custom-img-disk50gb-v0.0.3.iso"
  default = "ISO/debian-11.4.0-amd64-netinst.iso"
}

variable "vswitch_name" {
  description = "Provide a name for the vSwitch to be created. Ex vSwitch01"
  default = "vSwitch01"
}

variable "adapters" {
  default = ["vmnic0","vmnic1"]
}

variable "adapter_active" {
  default = ["vmnic0"]
}

variable "adapter_standby" {
  default = ["vmnic1"]
}

variable "pg_cfg" {
  type = map(object({
    name = string
    vlan = number
  }))
  default = {
    1 = {
      name = "pg-10"
      vlan = 10
    }
    2 = {
      name = "pg-11"
      vlan = 11
    }
  }
}
