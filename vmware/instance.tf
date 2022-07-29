resource "vsphere_host_virtual_switch" "host_virtual_switch" {
  name           = var.vswitch_name
  host_system_id = data.vsphere_host.host.id

  network_adapters = var.adapters 

  active_nics  = var.adapter_active 
  standby_nics = var.adapter_standby 
}

data "vsphere_datacenter" "datacenter" {
  name = var.data_center
}

data "vsphere_datastore" "datastore" {
  name          = var.data_store
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "esxi01.lab"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_host_port_group" "pg" {
  for_each            = var.pg_cfg
  name                = each.value["name"]
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = vsphere_host_virtual_switch.host_virtual_switch.name
  vlan_id = each.value["vlan"]

  allow_promiscuous = true
}

resource vsphere_role "role_operator" {
  name = "Operator"
  role_privileges = ["Alarm.Acknowledge", "Alarm.Create", "System.Read", "System.View"]
}
/*
resource "vsphere_license" "licenseKey" {
  license_key = "5H6C0-8CHD2-182G9-0V2H0-95UHJ"
}
*/
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