# OCI con Terraform y GitHub Actions: VM existente

Laboratorio de jesus-z en São Paulo (sa-saopaulo-1), adaptado del ejemplo de RekhuGopal.

## Arquitectura final

Terraform administra el compartimento jesus-z-oci-terraform-lab, la VCN vcn01,
la subred IC_pub_snet-A, su internet gateway, la tabla de rutas y la lista de seguridad.
El estado reside en el bucket privado jesus-z-terraform-state, con versionado y bloqueo.

El laboratorio consulta la VM existente atipax-docker-vm mediante data sources de OCI:
- Estado observado en OCI: RUNNING.
- Shape: VM.Standard.E2.1.Micro; 1 GB de RAM.
- IP pública observada: 137.131.247.197.
- La instancia conserva su VNIC y su red atipax-vcn.

La VM es un recurso externo consultado por este proyecto. Su ciclo de vida, sus
aplicaciones, sus claves SSH y su red original se administran fuera de este estado.
No se importó como recurso modificable ni se trasladó a la VCN del laboratorio.
El ejemplo muestra cómo combinar recursos creados con infraestructura existente.

## Configuración

Terraform/lab.auto.tfvars.json configura:
- create_instance = false
- existing_instance_id: OCID de atipax-docker-vm
- existing_vnic_id: OCID de su VNIC

Terraform/existing.tf consulta instancia, VNIC y subred. Los outputs incluyen
instance_id, instance_name, instance_state, instance_public_ip y existing_instance_vcn_id.
Los outputs compartment_id, vcn_id y subnet_id identifican la red nueva del laboratorio.

La clave SSH generada para la VM nueva que no pudo crearse NO da acceso a la VM
existente. Para conectarse a atipax-docker-vm debe usarse su clave SSH original.

## Ejecución

Actions > OCI Terraform > Run workflow > operation=plan o operation=apply.
El workflow ejecuta fmt, init, validate, plan y, cuando se elige apply, aplica el plan.
Usa Terraform 1.14.6 y el proveedor oracle/oci 7.x.

Secrets: OCI_USER_OCID, OCI_TENANCY_OCID, OCI_FINGERPRINT, OCI_KEY_FILE,
OCI_COMPARTMENT_OCID y OCI_SSH_SOURCE_CIDR. El último configura solamente la lista
de seguridad de la red nueva del laboratorio, no las reglas de la VM existente.
Las claves privadas no forman parte del repositorio ni del ZIP del código.

## Comprobaciones y alcance

Validación, plan y apply completados correctamente en GitHub Actions.
Resultado final: Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
El estado remoto incluye la VM existente como consulta, junto a los seis
recursos administrados de la red del laboratorio.

Se comprobó el estado RUNNING y la configuración de red mediante la API de OCI.
La consulta del sistema invitado mediante Oracle Cloud Agent no fue entregada y
se canceló. La petición HTTP externa agotó el tiempo de espera; no se verificó
la salud de la aplicación Docker ni el acceso SSH. Esta integración no despliega
aplicaciones dentro de la VM.

## Antecedente

Se intentó crear una segunda VM Always Free. OCI respondió Out of host capacity,
y los informes de capacidad marcaron Micro y A1 sin disponibilidad. El propietario
eligió reutilizar la VM existente y se deshabilitó la creación de una nueva.

Repositorio: https://github.com/jesus-z/OracleCloudInfrastructure
Origen: https://github.com/RekhuGopal/OracleCloudInfrastructure
Video: https://www.youtube.com/watch?v=3rmROBpBu9A

Ejecución correcta: https://github.com/jesus-z/OracleCloudInfrastructure/actions/runs/41949843850
