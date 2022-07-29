variable "vswitch_name" {
  description = "Provide a name for the vSwitch to be created. Ex vSwitch01"
  default = "vSwitch01"
}
variable "adapters" {
  default = ["vmnic2","vmnic3"]
}

variable "adapter_active" {
  default = ["vmnic2"]
}

variable "adapter_standby" {
  default = ["vmnic3"]
}

variable "pg_cfg" {
  type = map(object({
    name = string
    vlan = number
  }))
  default = {
    1 = {
      name = "pg-01"
      vlan = 1
    }
    2 = {
      name = "pg-02"
      vlan = 2
    }
    3 = {
      name = "pg-03"
      vlan = 3
    }
    4 = {
      name = "pg-04"
      vlan = 4
    }
    5 = {
      name = "pg-05"
      vlan = 4095
    }
  }
}

variable "data_center" {
  default = "dc-01"
}

variable "data_store" {
  default = "ds-01"
}

variable "server_vlan" {
  default = "pg-03"
}

variable "net_adapter_type" {
  default = "vmxnet3"
}

variable "guest_id" {
  default = "debian11_64Guest"
}

variable "custom_iso_path" {
  default = "ISO/debian-11.4.0-amd64-netinst.iso"
}

variable "name_new_vm" {
  description = "Input a name for Virtual Machine Ex. new_vm"
}

variable "vm_count" {
  description = "Number of instaces"
}

variable "disk_size" {
  description = "Amount of Disk, Ex. 50, 60, 70 OBS: The amount may not be less than 50"
}

variable "num_cpus" {
  description = "Amount of vCPU's, Ex. 2"
}

variable "num_mem" {
  description = "Amount of Memory, Ex. 1024, 2048, 3073, 4096"
}