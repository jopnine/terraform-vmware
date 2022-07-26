### 01 - Network

For the first steps you might want to setup all the VLANs,Virtual Switches,Port Group etc,
and for this we first need to setup our provider. 

For this example lets start creating the following resources:

* 01 Virtual Switch (vSwitch)

* 05 Port Groups (Each portgroup with a different VLAN tagged)

To start this lets begin creating another file to store our resources,
 in this laboratory we called it ``instance.tf``.

 The first resource we are going to create is ``vshpere_host_virtual_switch``

 ```hcl
resource "vsphere_host_virtual_switch" "host_virtual_switch" {
  name           = var.vswitch_name
  host_system_id = data.vsphere_host.host.id

  network_adapters = var.adapters 

  active_nics  = var.adapter_active 
  standby_nics = var.adapter_standby 
}
```

#### *Please note that we are already assigning variables in this resource.*

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `name`      | `string` | **Required**. The name of the virtual switch. |
| `host_system_id`      | `string` | **Required**. The managed object ID of the host to set the virtual switch up on. |
| `network_adapters`      | `list of string` | **Required**. The list of network adapters to bind to this virtual switch. |
| `active_nics`      | `list of string` | **Required**. List of active network adapters used for load balancing. |
| `active_nics`      | `list of string` | **Required**. List of standby network adapters used for failover. |

In our ``vars.tf`` file we now will setup all the variables created previously.

```hcl
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
```

 *In case you don't know what NICs you have, access your ESXI through CLI and run the command ``esxcli network nic list``
 and you will have a output like this:*
 ![logo](https://github.com/jopnine/terraform-vmware/blob/main/nic.png?raw=true)

We also need to include the following fields in order to ``host_system_id`` get a valid value.
```hcl
data "vsphere_datacenter" "datacenter" {
  name = "dc-01"
}
```
| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `name`      | `string` | **Optional**. The name of the datacenter. This can be a name or path. Can be omitted if there is only one datacenter in your inventory. |

```hcl
data "vsphere_host" "host" {
  name          = "esxi01.lab"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `name`      | `string` | **Optional**. The name of the host. This can be a name or path. If not provided, the default host is used. |
| `name`      | `string` | **Required**. The managed object ID of the datacenter to look for the host in. |


Now we need to create portgroups and assign in the resource we created above. In order to create
the portgroups we need include the following resource in the ``instance.tf``:
 ```hcl
resource "vsphere_host_port_group" "pg" {
  name                = "portgroup-01"
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = vsphere_host_virtual_switch.host_virtual_switch.name
}
```
| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `name`      | `string` | **Required**. The name of the port group. |
| `host_system_id`      | `string` | **Required**. The managed object ID of the host to set the virtual switch up on. |
| `virtual_switch_name`      | `string` | **Required**. The name of the virtual switch to bind this port group to. |
| `vlan_id`      | `number` | **Optional**. The VLAN ID/trunk mode for this port group. An ID of 0 denotes no tagging, an ID of 1-4094 tags with the specific ID, and an ID of 4095 enables trunk mode, allowing the guest to manage its own tagging. |
| `allow_promiscuous`      | `Bool` | **Optional**. Enable promiscuous mode on the network. This flag indicates whether or not all traffic is seen on a given port. |

Now we need to edit the resource in order to create all the VLANs we need for our enviroment.
In this example we are going to create 5 different VLANs with the following configurations:

| Portgroup | VLAN ID     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `pg-01`      | `1` | Portgroup assigned with VLAN 1, Uplink |
| `pg-02`      | `2` | Portgroup assigned with VLAN 2, Desktops VLAN |
| `pg-03`      | `3` | Portgroup assigned with VLAN 3, Servers VLAN |
| `pg-04`      | `4` | Portgroup assigned with VLAN 4, vMotion VLAN |
| `pg-05`      | `4095` | Portgroup in trunk |

*Please Note that all vlans above are just a example to ilustrate the usage.*

So we now need to edit our resource and assign variables and some parameters in order to create
multiple portgroups and assign VLANs.

```hcl
resource "vsphere_host_port_group" "pg" {
  for_each            = var.pg_cfg
  name                = each.value["name"]
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = vsphere_host_virtual_switch.host_virtual_switch.name
  vlan_id = each.value["vlan"]

  allow_promiscuous = true
}
```

We added **for_each** assigned with a var **pg_cfg** so we can assign different VLAN to multiple Portgroups.
To better understand how "for_each" works I recommend reading the [documentation](https://www.terraform.io/language/meta-arguments/for_each).
If you are not sure about allow_promiscuous , check **VMware KB** [1002934](https://kb.vmware.com/s/article/1002934)

Now we need to fill those variables with values, go to our ``vars.tf`` file and add the following code:

```hcl
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

```

*You can also create a file named ``terraform.tfvars`` and override the variables.*


