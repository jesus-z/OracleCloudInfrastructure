# Laboratorio OCI con Terraform y GitHub Actions

Adaptación del repositorio de RekhuGopal para jesus-z y sa-saopaulo-1.

Estado: preparación local. Todavía NO desplegado ni publicado en el fork.

Recursos: compartimento, VCN, subred pública, internet gateway y ruta de salida.
La VM del ejemplo se conserva como opción (create_instance = true). Antes de
habilitarla deben elegirse la imagen, availability domain y clave SSH propios.

## Configuración de GitHub Actions

Secrets requeridos:
- OCI_USER_OCID
- OCI_TENANCY_OCID
- OCI_FINGERPRINT
- OCI_KEY_FILE: clave privada PEM de una API key registrada en OCI
- OCI_COMPARTMENT_OCID: compartimento padre autorizado
- TF_HTTP_ADDRESS: URL PAR propia de lectura/escritura para un único objeto terraform.tfstate

No usar la URL de almacenamiento ni las claves del autor del video.
El backend HTTP de este laboratorio no ofrece bloqueo distribuido. El workflow
serializa las ejecuciones del repositorio; no ejecutar Terraform desde otros
repositorios ni localmente al mismo tiempo. La URL PAR es una credencial y debe
mantenerse en Secrets, con fecha de vencimiento definida y bucket privado.

## Ejecución

1. Configurar las credenciales y el objeto de estado propios.
2. Actions > OCI Terraform > Run workflow > plan.
3. Revisar el plan; después ejecutar operation=apply.
4. Confirmar recursos e identificadores en la consola de OCI.

El workflow instala Terraform 1.14.6 y usa el proveedor oracle/oci 7.x.
Se ha ejecutado terraform fmt. La instalación local del proveedor está bloqueada
por un error de acceso al calcular su checksum; falta ejecutar validate y plan.

Origen: https://github.com/RekhuGopal/OracleCloudInfrastructure
Video: https://www.youtube.com/watch?v=3rmROBpBu9A
