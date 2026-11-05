# Laboratorio OCI con Terraform y GitHub Actions

Adaptación del ejemplo de RekhuGopal para jesus-z, región sa-saopaulo-1.

## Resultado del despliegue

Se crearon y verificaron en OCI:
- Compartimento jesus-z-oci-terraform-lab.
- VCN vcn01 y subred IC_pub_snet-A.
- Internet gateway IC_IG-A y ruta de salida.
- Lista de seguridad lab-ssh, con SSH restringido al CIDR autorizado.
- Bucket privado jesus-z-terraform-state, con versionado habilitado.

La VM jesus-z-lab-vm está pendiente: OCI rechazó LaunchInstance con
500-InternalError: Out of host capacity. Los informes de capacidad devolvieron
OUT_OF_HOST_CAPACITY para E2 Micro y A1 Flex en los tres fault domains de São Paulo.
La VM existente atipax-docker-vm no fue modificada.

## Configuración de la VM pendiente

- Shape VM.Standard.E2.1.Micro, elegible para Always Free sujeto a los límites de la cuenta.
- Oracle Linux 9, imagen compatible de São Paulo.
- Volumen de arranque de 50 GB.
- Clave SSH pública propia incluida en lab.auto.tfvars.json.
- Acceso por SSH limitado al secreto OCI_SSH_SOURCE_CIDR, validado como IPv4 /32.

## Estado y credenciales

Terraform usa el backend nativo oci, con bloqueo de estado y autenticación APIKey.
backend.hcl contiene el bucket, namespace y región; no contiene la clave privada.
El estado se guarda en lab/terraform.tfstate dentro del bucket privado.

GitHub Actions usa los secretos OCI_USER_OCID, OCI_TENANCY_OCID,
OCI_FINGERPRINT, OCI_KEY_FILE, OCI_COMPARTMENT_OCID y OCI_SSH_SOURCE_CIDR.
La clave privada de API no está incluida en el repositorio ni en el ZIP del código.
La clave SSH privada se entrega por separado al propietario y tampoco se publica.

## Reintentar cuando OCI tenga capacidad

1. Abrir Actions > OCI Terraform > Run workflow.
2. Seleccionar operation=plan para revisar cambios pendientes.
3. Seleccionar operation=apply para reintentar el despliegue de la VM.

Terraform conserva los recursos ya creados mediante el estado remoto. No borrar
el bucket de estado ni sustituirlo por el almacenamiento del autor del video.
Si cambia la IP pública del equipo, actualizar OCI_SSH_SOURCE_CIDR con su nuevo /32
antes de aplicar. La VM recibirá una IP pública cuando OCI pueda crearla.

## Comprobaciones realizadas

- terraform fmt -check y terraform validate: correctos en GitHub Actions.
- Plan de red: 5 altas, 0 cambios, 0 eliminaciones.
- Plan de red y VM: 7 altas, 0 cambios, 0 eliminaciones.
- Apply: 6 recursos Terraform creados; VM rechazada por falta de capacidad.
- Plan posterior al apply: 1 alta (VM), 0 cambios, 0 eliminaciones.
- Verificación independiente mediante API de OCI: red disponible, bucket privado
  con versionado; ninguna VM creada en el compartimento del laboratorio.

Repositorio: https://github.com/jesus-z/OracleCloudInfrastructure
Intento de despliegue: https://github.com/jesus-z/OracleCloudInfrastructure/actions/runs/41947759337
Origen: https://github.com/RekhuGopal/OracleCloudInfrastructure
Video: https://www.youtube.com/watch?v=3rmROBpBu9A

Plan posterior correcto: https://github.com/jesus-z/OracleCloudInfrastructure/actions/runs/41947955687

