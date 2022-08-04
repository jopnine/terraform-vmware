
![logo](https://raw.githubusercontent.com/jopnine/terraform-vmware/main/images/image.png)


# How to setup a infrascruture using Terraform, VMware and Ansible

Here i will teach how to setup a whole enviroment using VMware, Terraform and Ansible. 





## Laboratory Enviroment

This is the enviroment we used in this example.

Brand: Dell Inc.

Model: PowerEdge R430

Specs: 

*   **CPU**	6 CPUs x Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

*   **Memory**	16 GB

*   **Storage** 512 GB 

ESXi-7.0U3d-19482537-standard (VMware, Inc.) 

* *If  you are using any dell hardware, you should try use a customized ESXi iso for it*

[How to download and install DELL EMC custom ESXi](https://www.dell.com/support/kbdoc/pt-br/000176963/dell-emc-customized-image-of-vmware-esxi-availability-and-download-instructions)

## References

[Hashicorp VMware](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs)

[GuestOS Var list](https://github.com/jopnine/terraform-vmware/blob/main/guestOS)

[Linux Hint](https://linuxhint.com/)
# Initial steps

Assuming that you will have a brand new vSphere Hypervisor (**ESXI HOST**) without anything configured,
first we need to setup and assign **Port groups**, **vSwitch** and **Physical NICS**. You can do
that by yourself using the UI interface or using the instructions below, in case you already have a 
enviroment "Ready-To-Work" you can skip this step.



### 01 - VMware Provider


```hcl
provider "vsphere" {
  # Configuration options
  vsphere_server       = "esxi01.lab"
  user                 = "YOURUSERNAMEHERE"
  password             = "YOURPASSWORDHERE"
  allow_unverified_ssl = true
}

```
| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `vsphere_server`      | `string` | **Required**. The vSphere Server name for vSphere API operations. |
| `user`      | `string` | **Required**. The user name for vSphere API operations. |
| `password`      | `string` | **Required**. The user password for vSphere API operations. |
| `allow_unverified_ssl`      | `bool` | **Required**. If set, VMware vSphere client will permit unverifiable SSL certificates. |

Is suggested to use it with variables like:

```hcl
provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}
```
If you are using variables create another file named "vars.tf" and paste the code below:

```hcl
variable "vsphere_server" {
  description = "The vSphere Server name for vSphere API operations."
}

variable "vsphere_user" {
  description = "The user name for vSphere API operations."
}

variable "vsphere_password" {
  description = "The user password for vSphere API operations."
}

```

This way you will be prompted to fill this on run, in case you don't want to be asked
 everytime you run ``terraform apply`` , you can avoid this by using a static value on the provider
, creating a .tfvars file, or simply by setting up a default value Ex.

```hcl
variable "vsphere_server" {
  default     = "esxi-node01.lab"
  description = "The vSphere Server name for vSphere API operations."
}

```

after setup the provider, we must declare which provider to use , so that Terraform can install
and use it. In the same folder you created the previous files you should now create another
file with any name you want it. (Terraform will read all files in the folder with the sufix .tf)

Create another file called ``main.tf`` and paste the following below.

```hcl
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
  required_version = ">= 1.2.0"
}
```


### 02 - Network

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
 ![nic](https://github.com/jopnine/terraform-vmware/blob/main/images/nic.png?raw=true)

We also need to include the following fields in order to ``host_system_id`` get a valid value.
```hcl
data "vsphere_datacenter" "datacenter" {
  name = var.data_center
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


Also we need to include the variable ``data_center`` in our ``vars.tf`` file.

```hcl
variable "data_center" {
  default = "dc-01"
}
```



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


## 03 - Security

When it comes to Security, how we handle roles and permissions is critical.
I suggest taking a look at VMware [Best Pratices](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.security.doc/GUID-FAA074CC-E8C9-4F13-ABCF-6CF7F15F04EE.html)

Now in ``instance.tf`` , let's create a default role for operators that need to have some access to alarms
and view some system info.




```hcl
resource vsphere_role "role_operator" {
  name = "Operator"
  role_privileges = ["Alarm.Acknowledge", "Alarm.Create", "System.Read", "System.View"]
}
```


| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `name`      | `string` | **Required**. Name of the role policy. |
| `name`      | `list of string` | **Optional**. Name of the role policy. |

This code above creates a role with name role_operator and privileges create, 
acknowledge for Alarm and create, read and view for System. While providing role_privileges, 
the id of the privilege has to be provided. The format of the privilege id is privilege 
name preceded by its categories joined by a ``.`` 

For example a privilege with path category->subcategory->
privilege should be provided as category.subcategory.privilege. 
Keep the role_privileges sorted alphabetically for a better user experience.

In case you want to create multiple roles, you should use the field **for_each** . 
## 04 - Administration

Now lets Provides a VMware vSphere license resource. This can be used to add and remove license keys.

```hcl
resource "vsphere_license" "licenseKey" {
  license_key = "452CQ-2EK54-K8742-00000-00000"
}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `license_key`      | `string` | **Required** The license key to add. |
| `labels`      | `map of string` | **Optional**. A map of key/value pairs to be attached as labels (tags) to the license key. |

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

![Apply](https://github.com/jopnine/terraform-vmware/blob/main/images/apply.png?raw=true)


## 06 - Installing Ansible

In the previous steps, we configured our environment using terraform to deploy three virtual machines. 
We decided to call them "labVM-1" , "labVM-2" and "labVM-3" they all have "Debian 11".

To begin, let's install ansible on **labVM-1**.

Start by updating the APT package repository cache:

```console
$ sudo apt update
```
![apt update](https://github.com/jopnine/terraform-vmware/blob/main/images/image02.png?raw=true)

Now let's check if python is installed.

```console
$ python3 -V
```
or 
```console
$ python -V
```
![python](https://github.com/jopnine/terraform-vmware/blob/main/images/image03.png?raw=true)

*Most linux distros come with python already installed*

If you don't have **Python** installed, don't worry because the following command already downloads and installs 
Ansible as well as its dependencies. Eg: "Python pip"

```console
$ sudo apt install ansible
```

![confirm](https://github.com/jopnine/terraform-vmware/blob/main/images/image04.png?raw=true)

Confirm the installation by pressing Y and then Enter.

To verify if Ansible is installed and working, run the command below:

```console
$ ansible --version
```
![ansible version](https://github.com/jopnine/terraform-vmware/blob/main/images/image05.png?raw=true)

Continuing where we left off, we will now generate an SSH key so that our virtual machine "labVM-1" can connect to the other virtual machines without need to input a password.
Run the following command.

```console
$ ssh-keygen
```
![keygen](https://github.com/jopnine/terraform-vmware/blob/main/images/image06.png?raw=true)

Then press **Enter**.

![keygen](https://github.com/jopnine/terraform-vmware/blob/main/images/image07.png?raw=true)

Press **Enter** again.

![keygen](https://github.com/jopnine/terraform-vmware/blob/main/images/image08.png?raw=true)

Now your SSH key is generated.

![keygen](https://github.com/jopnine/terraform-vmware/blob/main/images/image09.png?raw=true)

## 07 - Configuring Hosts

Okay, now we've finished installing "Ansible" and we're ready to start configuring hosts to it.

The following steps:

* Check if the APT package repository cache is updated with the following command:

```console
$ sudo apt update
```

Now you need to check if you have the package OpenSSH installed, running and enabled. 
This is crucial because Ansible uses SSH to access the host. You can check it by running

```console
$ sudo systemctl status sshd
```

![ssh](https://github.com/jopnine/terraform-vmware/blob/main/images/image10.png?raw=true)

*You can see in the image above the service is **ACTIVE** and **ENABLED**.*

In case you don't have it installed, run the following command:

```console
$ sudo apt install openssh-server -y
```

Then start the **sshd** service manually by using the following command:

```console
$ sudo systemctl start sshd
```

Now you need to enable it (add it to the system startup), in order to do it, run the following command:

```console
$ sudo systemctl enable sshd
```
Run again the command ``
$ sudo systemctl status sshd
`` to verify if the service is **ACTIVE** and **ENABLED**. 
Then let's create a user for **Ansible** with sudo access and auth through the SSH key we generated earlier. In order to do so, run the following command.

```console
$ sudo adduser --shell /bin/bash --gecos "" ansible
```

Type in a password press **Enter**.

Retype the password and press **Enter** again.

![ansible user](https://github.com/jopnine/terraform-vmware/blob/main/images/image11.png?raw=true)

In order to authorize the authentication through certificate in the **ansible** user, edit the file
**/etc/sudoers** with the following command:

```console
$ sudo visudo
```

Then add the line:
```console
ansible ALL=(ALL) NOPASSWD:ALL
```
![sudoers file](https://github.com/jopnine/terraform-vmware/blob/main/images/image12.png?raw=true)

And save the file by pressing **CTRL + X** followed by Y and the press **Enter**. Now find the IP address of the host by
running the following command.

```console
$ ip addr
```
![ip address](https://github.com/jopnine/terraform-vmware/blob/main/images/image13.png?raw=true)

Now we've made sure the host have a user and SSH service for ansible to access, let's proceed
with the magic, in our virtual machine where we installed Ansible (**labVM-1**), copy the SSH public key
to the Ansible host (**labVM-2**) with the following command:

```console
$ ssh-copy-id ansible@10.200.0.106
```
When prompted ``Are you sure you want to continue connecting (Yes/no[fingerprint])?`` Type in **yes** and press **Enter**.
Next, type in the password for the user ``ansible`` that we created above and press **Enter**.
The SSH public key we generated before is now copied to the host (**labVM-2**)

![ssh copied](https://github.com/jopnine/terraform-vmware/blob/main/images/image14.png?raw=true)

Now we should be able to SSH into the host **labVM-2** without any password and run sudo commands without being prompted
for any password. In order to improve security, let's connect again on our host **labVM-2** and run the following code in order to
disable password-based login for the **ansible** user:

```console
$ sudo usermod -L ansible
```

Next, back on our virtual machine where we had installed ansible (**labVM-1**), Let's create a new
directory **~/workspace/** using the following code:

```console
$ mkdir ~/workspace
```
Navigate to the **~/workspace/** directory using the following code:

```console
cd ~/workspace/
```

Create a new **hosts** file using the following code:

```console
$ nano hosts
```

Next, list the IP/DNS of the hosts (In our case, **labVM-2** & **labVM-3**) in the hosts file:

```yml
## set up ssh user name and path to python3 ##
[all:vars]
ansible_user='ubuntu'
ansible_become=yes
ansible_become_method=sudo
ansible_python_interpreter='/usr/bin/env python3'
 
##########################
## The hosts that you wish this playbook to be applied.
###########################
[servers]
10.200.0.106
10.200.0.108
```
![hosts](https://github.com/jopnine/terraform-vmware/blob/main/images/image15.png?raw=true)

And save the file by pressing **CTRL + X** followed by Y and the press **Enter**, Then create a new **update.yml** file using the following code:

```console
$ nano update.yml
```

```yml
---
- hosts: servers
  become: true
  become_user: root
  tasks:
    - name: Update apt repo and cache on all Debian/Ubuntu boxes
      apt: update_cache=yes force_apt_get=yes cache_valid_time=3600

    - name: Upgrade all packages on servers
      apt: upgrade=dist force_apt_get=yes

    - name: Check if a reboot is needed on all servers
      register: reboot_required_file
      stat: path=/var/run/reboot-required get_md5=no

    - name: Reboot the box if kernel updated
      reboot:
        msg: "Reboot initiated by Ansible for kernel updates"
        connect_timeout: 5
        reboot_timeout: 300
        pre_reboot_delay: 0
        post_reboot_delay: 30
        test_command: uptime
      when: reboot_required_file.stat.exists
```
Save the file by pressing **CTRL + X** followed by Y and the press **Enter**, then execute the following code to test the hosts connections:

```console
$ ansible -i ./hosts all -u ansible -m ping
```

![hosts](https://github.com/jopnine/terraform-vmware/blob/main/images/image16.png?raw=true)

All hosts must respond with **SUCCESS** if not. Check previous steps. 
If all hosts respond with **SUCCESS** we will run the "playbook" we created above with the following command:

```console
$ ansible-playbook -i hosts update.yml
```
![update.yml](https://github.com/jopnine/terraform-vmware/blob/main/images/image17.png?raw=true)

Finally, we've made and run a "Playbook" that updates all packages and restarts the host if necessary.

