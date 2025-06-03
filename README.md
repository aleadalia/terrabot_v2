# 🤖 TerraBot - Bot de Discord Sin Servidor
Un bot de Discord ligero y sin servidor desplegado en AWS Lambda usando Terraform. Comienza rápidamente con configuración mínima.

## 🚀 Inicio Rápido

### Prerrequisitos
- [Cuenta de AWS](https://aws.amazon.com/)
- [Terraform](https://www.terraform.io/downloads.html)
- [Python 3.9+](https://www.python.org/downloads/)
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- [Cuenta de Desarrollador de Discord](https://discord.com/developers/applications)

### Configuración

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/terrabotv2.git
   cd terrabotv2
   ```

2. **Configurar entorno de Python**
   ```bash
   python -m venv venv
   .\venv\Scripts\activate  # Windows
   # O
   source venv/bin/activate  # Mac/Linux
   
   pip install -r requirements.txt
   ```

3. **Configurar Bot de Discord**
   - Crear una nueva aplicación en [Portal de Desarrolladores de Discord](https://discord.com/developers/applications)
   - Crear un bot y copiar el token
   - Habilitar todos los intents

4. **Configurar Entorno**
   Crear archivo `.env`:
   ```
   DISCORD_TOKEN=tu_token_del_bot_aqui
   DISCORD_PUBLIC_KEY=tu_clave_publica_aqui
   DISCORD_APPLICATION_ID=tu_id_de_aplicacion_aqui
   ```

### 🚀 Desplegar

1. **Desplegar en AWS**
   ```bash
   # Windows
   .\deploy.ps1
   
   # Linux/Mac
   chmod +x deploy.sh
   ./deploy.sh
   ```

2. **Configurar Webhook de Discord**
   - Copiar la URL del API Gateway de la salida
   - Ir al Portal de Desarrolladores de Discord > Tu App > Información General
   - Establecer "URL del Endpoint de Interacciones" a tu URL del API Gateway

### 🤖 Probar tu Bot

1. Invitar el bot a tu servidor:
   ```
   https://discord.com/api/oauth2/authorize?client_id=TU_CLIENT_ID&permissions=0&scope=bot%20applications.commands
   ```

2. Probar el comando:
   ```
   /ping
   ```

## 📁 Estructura del Proyecto

```
terrabotv2/
├── bot.py               # Código principal del bot
├── requirements.txt     # Dependencias de Python
├── .env                # Variables de entorno
├── deploy.ps1          # Script de despliegue para Windows
├── deploy.sh           # Script de despliegue para Linux/Mac
└── terraform/          # Infraestructura como Código
    ├── main.tf         # Configuración principal de Terraform
    ├── variables.tf    # Definiciones de variables
    └── outputs.tf      # Configuraciones de salida
```

## 🛠️ Añadir Comandos

Editar `bot.py` para añadir nuevos comandos slash:

```python
@tree.command(name="hola", description="Decir hola")
async def hola(interaction: discord.Interaction):
    await interaction.response.send_message(f"¡Hola {interaction.user.mention}!")
```

## 🔧 Solución de Problemas

- **¿El bot no responde?** Revisar los logs de CloudWatch en la Consola de AWS
- **¿401 No Autorizado?** Verificar tu clave pública y token de Discord
- **¿Problemas de despliegue?** Ejecutar `terraform init` e intentar nuevamente

## 🧹 Limpiar

Para eliminar todos los recursos de AWS:

```bash
cd terraform
terraform destroy -var="discord_token=$env:DISCORD_TOKEN" -var="discord_public_key=$env:DISCORD_PUBLIC_KEY" -auto-approve
```
