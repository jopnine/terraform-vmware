# Configure the vSphere Provider
provider "vsphere" {
  vsphere_server       = "esxi.lab"
  user                 = ""
  password             = ""
  allow_unverified_ssl = true
}
