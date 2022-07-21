data "vsphere_datacenter" "datacenter" {
  name = "dc-01"
}

data "vsphere_host" "host" {
  name          = "esxi-01.example.com"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_host_virtual_switch" "host_virtual_switch" {
  name           = var.vswitch_name
  host_system_id = data.vsphere_host.host.id

  network_adapters = var.adapters // The list of network adapters to bind to this virtual switch

  active_nics  = var.adapter_active //List of active network adapters used for load balancing.
  standby_nics = var.adapter_standby //List of standby network adapters used for failover.
}

resource "vsphere_host_port_group" "pg" {
  for_each = var.pg_cfg
  name                = each.value["name"]
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = vsphere_host_virtual_switch.host_virtual_switch.name
  vlan_id = each.value["vlan"]

  allow_promiscuous = true
}
