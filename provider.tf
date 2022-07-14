# Configure the vSphere Provider
provider "vsphere" {
  vsphere_server       = "esxi-node-1.intra.lab"
  user                 = ""
  password             = ""
  allow_unverified_ssl = true
}
