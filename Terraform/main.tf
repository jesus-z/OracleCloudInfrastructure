# main.tf
locals {
  cmpt_name_prefix = "jesus-z"

}

############################################
# Compartments
############################################
resource "oci_identity_compartment" "example_compartment" {
  # Required
  compartment_id = var.compartment_id
  description    = var.compartment_description
  name           = "${local.cmpt_name_prefix}-${var.compartment_name}"
}

############################################
# VCN
############################################

resource "oci_core_vcn" "example_vcn" {
  #Required
  compartment_id = oci_identity_compartment.example_compartment.id
  cidr_blocks    = var.vcn1.cidr_blocks
  #Optional
  display_name = var.vcn1.display_name
}

############################################
# Public Subnet
############################################

resource "oci_core_subnet" "subnetA_pub" {
  #Required
  compartment_id    = oci_identity_compartment.example_compartment.id
  vcn_id            = oci_core_vcn.example_vcn.id
  cidr_block        = var.subnetA_pub.cidr_block
  security_list_ids = [oci_core_security_list.lab.id]
  #Optional
  display_name               = var.subnetA_pub.display_name
  prohibit_public_ip_on_vnic = !var.subnetA_pub.is_public
  prohibit_internet_ingress  = !var.subnetA_pub.is_public
}

resource "oci_core_security_list" "lab" {
  compartment_id = oci_identity_compartment.example_compartment.id
  vcn_id         = oci_core_vcn.example_vcn.id
  display_name   = "lab-ssh"
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  dynamic "ingress_security_rules" {
    for_each = var.ssh_source_cidr == "" ? [] : [var.ssh_source_cidr]
    content {
      protocol    = "6"
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      description = "SSH desde la IP autorizada"
      tcp_options {
        min = 22
        max = 22
      }
    }
  }
}

############################################
# Internet Gateways and NAT Gateways
############################################

resource "oci_core_internet_gateway" "the_internet_gateway" {
  compartment_id = oci_identity_compartment.example_compartment.id
  vcn_id         = oci_core_vcn.example_vcn.id
  display_name   = var.internet_gateway_A.display_name
}


############################################
# Route Tables
############################################

resource "oci_core_default_route_table" "the_route_table" {
  #Required
  compartment_id             = oci_identity_compartment.example_compartment.id
  manage_default_resource_id = oci_core_vcn.example_vcn.default_route_table_id
  # Optional
  display_name = var.subnetA_pub.route_table.display_name
  dynamic "route_rules" {
    for_each = [true]
    content {
      destination       = var.internet_gateway_A.ig_destination
      description       = var.subnetA_pub.route_table.description
      network_entity_id = oci_core_internet_gateway.the_internet_gateway.id
    }
  }
}

# ############################################
# # Compute Instance
# ############################################

resource "oci_core_instance" "ic_pub_vm-A" {
  count               = var.create_instance ? 1 : 0
  compartment_id      = oci_identity_compartment.example_compartment.id
  shape               = var.ic_pub_vm_A.shape.name
  availability_domain = var.ic_pub_vm_A.availability_domain
  display_name        = var.ic_pub_vm_A.display_name

  source_details {
    source_id               = var.ic_pub_vm_A.image_ocid
    source_type             = "image"
    boot_volume_size_in_gbs = 50
  }

  dynamic "shape_config" {
    for_each = endswith(var.ic_pub_vm_A.shape.name, ".Flex") ? [true] : []
    content {
      #Optional
      memory_in_gbs = var.ic_pub_vm_A.shape.memory_in_gbs
      ocpus         = var.ic_pub_vm_A.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnetA_pub.id
    assign_public_ip = var.ic_pub_vm_A.assign_public_ip
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.ic_pub_vm_A.ssh_authorized_keys : chomp(k)])
  }
}
