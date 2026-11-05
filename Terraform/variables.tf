# main-vars.tf
############################################
# Compartments
############################################

variable "compartment_id" {
  description = "The OCID of the parent compartment where the resources will be created."
  type        = string
}

variable "compartment_name" {
  description = "Compartment Name"
  type        = string
  default     = "cloudquicklabs-compartment"
}

variable "compartment_description" {
  description = "Compartment Description"
  type        = string
  default     = "test-compartment description"
}

############################################
# VCN
############################################

variable "vcn1" {
  description = "The details of VCN1."
  default = {
    cidr_blocks : ["10.23.0.0/20"]
    display_name : "vcn01"
  }
}

############################################
# Public Subnet, Route Table, and Internet Gateway
############################################

variable "subnetA_pub" {
  description = "The details of the subnet"
  default = {
    cidr_block : "10.23.11.0/24"
    display_name : "IC_pub_snet-A"
    is_public : true
    route_table : {
      display_name = "routeTable-Apub"
      description  = "routeTable-Apub"
    }
  }
}

variable "internet_gateway_A" {
  description = "The details of the internet gateway"
  default = {
    display_name : "IC_IG-A"
    ig_destination = "0.0.0.0/0"
  }
}

############################################
# Compute Instance
############################################

variable "create_instance" {
  description = "Crear la VM del laboratorio; requiere image OCID, AD y clave SSH propios."
  type        = bool
  default     = false
}

variable "ic_pub_vm_A" {
  description = "Datos regionales de la VM; configurar antes de habilitar create_instance."
  type = object({
    display_name        = string
    assign_public_ip    = bool
    availability_domain = string
    image_ocid          = string
    shape = object({
      name          = string
      ocpus         = number
      memory_in_gbs = number
    })
    ssh_authorized_keys = list(string)
  })
  default = {
    display_name        = "lab-vm"
    assign_public_ip    = true
    availability_domain = ""
    image_ocid          = ""
    shape = {
      name          = "VM.Standard.E2.1.Micro"
      ocpus         = 1
      memory_in_gbs = 1
    }
    ssh_authorized_keys = []
  }
  validation {
    condition     = !var.create_instance || (var.ic_pub_vm_A.image_ocid != "" && var.ic_pub_vm_A.availability_domain != "" && length(var.ic_pub_vm_A.ssh_authorized_keys) > 0)
    error_message = "Para crear la VM configura image_ocid, availability_domain y ssh_authorized_keys de tu cuenta y región."
  }
}
