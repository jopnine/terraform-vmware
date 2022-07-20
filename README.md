
![logo](https://raw.githubusercontent.com/jopnine/terraform-vmware/main/image.png)


# How to setup a infrascruture using Terraform, VMware and Ansible (WIP)

Here i will teach how to setup a whole enviroment using VMware, Terraform and Ansible.



## References

In this project we will be using the following links:

[vmware](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs)

[GuestOS Var list](https://github.com/jopnine/terraform-vmware/blob/main/guestOS)
## Initial steps

Assuming that you will have a brand new vSphere Hypervisor (**ESXI HOST**) without anything configured,
first we need to setup and assign **Port groups**, **vSwitch** and **Physical NICS**. You can do
that by yourself using the UI interface or using the instructions below, in case you already have a 
enviroment "Ready-To-Work" you can skip this step.
