
![logo](https://raw.githubusercontent.com/jopnine/terraform-vmware/main/image.png)


# How to setup a infrascruture using Terraform, VMware and Ansible (WIP)

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

In this project we will be using the following links:

[vmware](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs)

[GuestOS Var list](https://github.com/jopnine/terraform-vmware/blob/main/guestOS)
# Initial steps

Assuming that you will have a brand new vSphere Hypervisor (**ESXI HOST**) without anything configured,
first we need to setup and assign **Port groups**, **vSwitch** and **Physical NICS**. You can do
that by yourself using the UI interface or using the instructions below, in case you already have a 
enviroment "Ready-To-Work" you can skip this step.



### 01 - Network

For the first steps you might want to setup all the VLANs,Virtual Switches,Port Group etc,
and for this we first need to setup our provider. 

Create a file named 'provider.tf' and paste the code below.


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

Is suggested to use it with vars like:

```hcl
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}
```
Then create another file named "vars.tf"



