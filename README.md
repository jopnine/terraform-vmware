
![logo](https://raw.githubusercontent.com/jopnine/terraform-vmware/main/image.png)


# How to setup a infrascruture using Terraform, VMware and Ansible (WIP)

Here i will teach how to setup a whole enviroment using VMware, Terraform and Ansible.



## Laboratory Enviroment

This is the enviroment we used in this example.

Brand: Dell Inc.

Model: PowerEdge R430

Specs: 6 CPUs x Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

ESXi-7.0U3d-19482537-standard (VMware, Inc.) 

* *If  you are using any dell hardware, you should try use a customized ESXi iso for it*

[How to download and install DELL EMC custom ESXi](https://www.dell.com/support/kbdoc/pt-br/000176963/dell-emc-customized-image-of-vmware-esxi-availability-and-download-instructions)

## References

In this project we will be using the following links:

[vmware](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs)

[GuestOS Var list](https://github.com/jopnine/terraform-vmware/blob/main/guestOS)
## Initial steps

Assuming that you will have a brand new vSphere Hypervisor (**ESXI HOST**) without anything configured,
first we need to setup and assign **Port groups**, **vSwitch** and **Physical NICS**. You can do
that by yourself using the UI interface or using the instructions below, in case you already have a 
enviroment "Ready-To-Work" you can skip this step.
