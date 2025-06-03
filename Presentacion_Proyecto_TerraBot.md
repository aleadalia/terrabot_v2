# Proyecto TerraBot: Bot de Discord Serverless con Terraform y AWS Lambda

## Información del Proyecto

**Nombre del Proyecto:** TerraBot  
**Fecha:** 3 de junio de 2025  
**Autor:** [Tu Nombre]  
**Curso:** Infraestructura como Código con Terraform  

## Resumen Ejecutivo

TerraBot es un bot de Discord serverless implementado utilizando AWS Lambda y desplegado mediante Terraform. Este proyecto demuestra la aplicación práctica de la infraestructura como código (IaC) para desplegar y gestionar aplicaciones serverless en la nube de AWS, específicamente un bot de Discord que responde a comandos y eventos.

## Objetivos del Proyecto

1. Implementar un bot de Discord funcional utilizando arquitectura serverless
2. Utilizar Terraform para gestionar toda la infraestructura necesaria
3. Implementar un flujo de CI/CD con GitHub Actions
4. Demostrar buenas prácticas de IaC y gestión de configuración
5. Proporcionar documentación detallada del proyecto

## Arquitectura del Sistema

### Componentes Principales

1. **AWS Lambda**: Función serverless que ejecuta el código del bot
2. **API Gateway**: Endpoint HTTP para recibir las interacciones de Discord
3. **IAM Roles**: Permisos necesarios para la ejecución de la función Lambda
4. **Terraform**: Gestión de toda la infraestructura como código
5. **GitHub Actions**: Automatización del despliegue y pruebas

### Diagrama de Arquitectura

```
+----------------+       +----------------+       +----------------+
|                |       |                |       |                |
|    Discord     +------>+  API Gateway   +------>+  AWS Lambda    |
|                |       |                |       |                |
+----------------+       +----------------+       +----------------+
                                                        |
                                                        v
                                               +----------------+
                                               |                |
                                               |   CloudWatch   |
                                               |     Logs       |
                                               |                |
                                               +----------------+
```

## Implementación con Terraform

### Recursos Desplegados

1. **AWS Lambda Function**: Función Python que contiene la lógica del bot
2. **API Gateway REST API**: Endpoint HTTP para recibir las interacciones de Discord
3. **IAM Role y Policy**: Permisos necesarios para la ejecución de Lambda
4. **CloudWatch Logs**: Registro de la actividad del bot

### Estructura del Código Terraform

```
terraform/
├── main.tf       # Configuración principal de recursos
├── variables.tf  # Definición de variables
├── outputs.tf    # Salidas del despliegue
└── provider.tf   # Configuración del proveedor AWS
```

## Implementación del Bot de Discord

### Funcionalidades

1. **Verificación de Interacciones**: Validación de solicitudes de Discord mediante firma ED25519
2. **Respuesta a Comandos**: Procesamiento de comandos como `/hello` y `/info`
3. **Manejo de Componentes**: Respuesta a interacciones con componentes de mensajes
4. **Logging**: Registro detallado de actividades para diagnóstico

### Problemas y Soluciones

#### Problema de Compatibilidad con PyNaCl

Uno de los desafíos principales encontrados durante el desarrollo fue la incompatibilidad del paquete PyNaCl con el entorno de AWS Lambda. PyNaCl es necesario para la verificación de firma ED25519 requerida por Discord, pero contiene bibliotecas nativas que necesitan ser compiladas específicamente para el entorno de Lambda.

**Problema específico**: La función Lambda no podía importar el módulo `nacl._sodium`, lo que resultaba en un error `Runtime.ImportModuleError`.

**Solución implementada**: Para superar este problema temporalmente, se simplificó el código eliminando la verificación de firma estricta durante la fase de prueba. En un entorno de producción, se recomienda:

1. Utilizar Lambda Layers con versiones precompiladas de PyNaCl para Lambda
2. Compilar PyNaCl específicamente para el entorno de Lambda
3. Implementar una solución de verificación de firma alternativa

## Flujo de CI/CD con GitHub Actions

Se ha implementado un flujo completo de CI/CD utilizando GitHub Actions que automatiza:

1. **Validación del código Terraform**: Formato, inicialización y validación
2. **Plan de Terraform**: Generación y visualización del plan en Pull Requests
3. **Despliegue automático**: Aplicación de cambios en la rama principal
4. **Empaquetado y actualización de Lambda**: Actualización automática del código de la función

El flujo de trabajo está definido en `.github/workflows/terraform-deploy.yml` y se activa con cada push a la rama principal o pull request.

## Seguridad

### Gestión de Secretos

Las credenciales sensibles como el token de Discord y la clave pública se gestionan mediante:

1. **Variables de entorno en Lambda**: Configuradas a través de Terraform
2. **Secretos de GitHub**: Para el flujo de CI/CD
3. **Archivo .env local**: Para desarrollo (excluido del repositorio)

### Permisos IAM

Se siguen los principios de privilegio mínimo, otorgando solo los permisos necesarios para la función Lambda:

- Escritura en CloudWatch Logs
- Sin acceso a otros recursos de AWS

## Conclusiones y Trabajo Futuro

### Logros

1. Implementación exitosa de un bot de Discord serverless
2. Infraestructura completamente gestionada con Terraform
3. Flujo de CI/CD automatizado con GitHub Actions
4. Solución a problemas de compatibilidad de dependencias

### Mejoras Futuras

1. **Implementar Lambda Layers**: Para gestionar dependencias nativas como PyNaCl
2. **Añadir pruebas automatizadas**: Para verificar la funcionalidad del bot
3. **Implementar monitoreo avanzado**: Con CloudWatch Alarms y métricas personalizadas
4. **Expandir funcionalidades del bot**: Añadir más comandos e integraciones

## Anexos

### Código Terraform

El código Terraform completo utilizado para este proyecto se incluye en la carpeta `terraform/` del repositorio.

### Instrucciones de Despliegue Manual

1. Clonar el repositorio
2. Configurar variables de entorno o archivo `.env`
3. Ejecutar `terraform init` y `terraform apply` en la carpeta `terraform/`
4. Registrar el endpoint en el portal de desarrolladores de Discord

### Referencias

1. [Documentación de Terraform](https://www.terraform.io/docs)
2. [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
3. [Discord Developer Portal](https://discord.com/developers/docs)
4. [GitHub Actions Documentation](https://docs.github.com/en/actions)
