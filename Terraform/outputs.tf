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
  value = try(oci_core_instance.ic_pub_vm-A[0].public_ip, null)
}
