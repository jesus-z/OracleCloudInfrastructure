data "oci_core_instance" "existing" {
  count       = var.existing_instance_id != "" ? 1 : 0
  instance_id = var.existing_instance_id
}

data "oci_core_vnic" "existing" {
  count   = var.existing_instance_id != "" ? 1 : 0
  vnic_id = var.existing_vnic_id
}

data "oci_core_subnet" "existing" {
  count     = var.existing_instance_id != "" ? 1 : 0
  subnet_id = data.oci_core_vnic.existing[0].subnet_id
}
