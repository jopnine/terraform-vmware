vswitch_name = "vswt-01"
adapters = ["vmnic2","vmnic3"]
adapter_active = ["vmnic2"]
adapter_standby = ["vmnic3"]
pg_cfg = {
    1 = {
      name = "pg-3939"
      vlan = 3939
    }
    2 = {
      name = "pg-01"
      vlan = 1
    }
    3 = {
      name = "pg-02"
      vlan = 2
    }
    4 = {
      name = "pg-04"
      vlan = 4
    }
    5 = {
      name = "pg-05"
      vlan = 5
    }
    6 = {
      name = "pg-10"
      vlan = 10
    }
    7 = {
      name = "pg-11"
      vlan = 11
    }
    8 = {
      name = "pg-12"
      vlan = 12
    }
    9 = {
      name = "pg-13"
      vlan = 13
    }
    10 = {
      name = "pg-15"
      vlan = 15
    }
    11 = {
      name = "pg-16"
      vlan = 16
    }
    12 = {
      name = "pg-17"
      vlan = 17
    }
    13 = {
      name = "pg-100"
      vlan = 100
    }
    14 = {
      name = "pg-202"
      vlan = 202
    }
    15 = {
      name = "pg-203"
      vlan = 203
    }
    16 = {
      name = "pg-30"
      vlan = 30
    }
  }