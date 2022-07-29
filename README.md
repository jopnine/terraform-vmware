
## 05 - Deploying VMs

Now to deploy the virtual machines, we need to include this resource.


```hcl
data "vsphere_network" "networking" {
  name          = var.server_vlan
  datacenter_id = data.vsphere_datacenter.datacenter.id
  depends_on = [vsphere_host_port_group.pg]
}

data "vsphere_resource_pool" "pool" {
}

resource "vsphere_virtual_machine" "virtualmachine" {
  count                      = var.vm_count
  name                       = "${var.name_new_vm}-${count.index + 1}"
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  force_power_off            = true
  shutdown_wait_timeout      = 1
  num_cpus                   = var.num_cpus
  memory                     = var.num_mem
  wait_for_guest_net_timeout = 0
  guest_id                   = var.guest_id
  nested_hv_enabled          = true
  
  network_interface {
    network_id   = data.vsphere_network.networking.id
    adapter_type = var.net_adapter_type
  }
  
  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.custom_iso_path
  }
  disk {
    size             = var.disk_size
    label            = "first-disk.vmdk"
    eagerly_scrub    = false
    thin_provisioned = true
  }
}
```


| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `count`      | `number` | **Optional**. Number of instances of this resource, e.g. 3 |
| `name`      | `string` | **Required**. The name of this virtual machine. |
| `resource_pool_id`      | `string` | **Required**. The ID of a resource pool to put the virtual machine in. |
| `datastore_id`      | `string` | **Optional**. The ID of the virtual machine's datastore. The virtual machine configuration is placed here, along with any virtual disks that are created without datastores. |
| `force_power_off`      | `bool` | **Optional**. Set to true to force power-off a virtual machine if a graceful guest shutdown failed for a necessary operation. |
| `shutdown_wait_timeout`      | `number` | **Optional**. The amount of time, in minutes, to wait for shutdown when making necessary updates to the virtual machine. |
| `num_cpus`      | `number` | **Optional**. The number of virtual processors to assign to this virtual machine. |
| `memory`      | `number` | **Optional**. The size of the virtual machine's memory, in MB |
| `wait_for_guest_net_timeout`      | `number` | **Optional**. The amount of time, in minutes, to wait for an available IP address on this virtual machine. A value less than 1 disables the waiter. |
| `guest_id`      | `string` | **Optional**. The guest ID for the operating system. |
| `nested_hv_enabled`      | `bool` | **Optional**. Enable nested hardware virtualization on this virtual machine, facilitating nested virtualization in the guest. |
| `network_interface`      | `list` | **Required**. A specification for a virtual NIC on this virtual machine. |
| `network_id`      | `string` | **Required**. The ID of the network to connect this network interface to. |
| `adapter_type`      | `string` | **Optional**. The controller type. Can be one of e1000, e1000e, or vmxnet3. |
| `cdrom`      | `list` | **Optional**. A specification for a CDROM device on this virtual machine. |
| `disk`      | `list` | **Required**. A specification for a virtual disk device on this virtual machine. |

*Note that we have added the parameter ``depends_on = [vsphere_host_port_group.pg]`` so we can avoid terraform not finding our port group while trying to create VMs.*

As for the variables, in ``vars.tf`` we will add the following code:

```hcl

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
  default = "centos7_64Guest"
}

variable "custom_iso_path" {
  default = "iso/centos7-custom-img-disk50gb-v0.0.3.iso"
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
```

*You can found a list with all possible values for the variable "guest_id" [here](https://github.com/jopnine/terraform-vmware/blob/main/guestOS)*

Now you can run ``terraform apply`` and will be prompted to set a value for the variables without a default
value.

![Apply](https://github.com/jopnine/terraform-vmware/blob/main/apply.png?raw=true)

