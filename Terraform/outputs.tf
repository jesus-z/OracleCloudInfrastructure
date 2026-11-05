output "compartment_id" {
  value = oci_identity_compartment.example_compartment.id
}
output "vcn_id" {
  value = oci_core_vcn.example_vcn.id
}
output "subnet_id" {
  value = oci_core_subnet.subnetA_pub.id
}
output "instance_public_ip" {
  value = var.create_instance ? try(oci_core_instance.ic_pub_vm-A[0].public_ip, null) : try(data.oci_core_vnic.existing[0].public_ip_address, null)
}

output "instance_id" {
  value = var.create_instance ? try(oci_core_instance.ic_pub_vm-A[0].id, null) : try(data.oci_core_instance.existing[0].id, null)
}

output "instance_name" {
  value = var.create_instance ? try(oci_core_instance.ic_pub_vm-A[0].display_name, null) : try(data.oci_core_instance.existing[0].display_name, null)
}

output "instance_state" {
  value = var.create_instance ? try(oci_core_instance.ic_pub_vm-A[0].state, null) : try(data.oci_core_instance.existing[0].state, null)
}

output "existing_instance_vcn_id" {
  value = try(data.oci_core_subnet.existing[0].vcn_id, null)
}
