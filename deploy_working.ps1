# Script de despliegue para TerraBot
# Este script evita problemas con caracteres especiales en PowerShell

# Verificar si existe el archivo .env
if (-not (Test-Path .\.env)) {
    Write-Error "Error: No se encontró el archivo .env. Por favor, crea uno basado en .env.example"
    exit 1
}

# Cargar variables de entorno
Write-Host "📝 Cargando variables de entorno..."
$envContents = Get-Content .\.env
foreach ($line in $envContents) {
    if ($line -match '^\s*([^=\s]+)\s*=\s*(.+?)\s*$') {
        $name = $matches[1]
        $value = $matches[2]
        [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

# Crear directorio para el paquete
Write-Host "🚀 Instalando dependencias de Python..."
if (Test-Path .\package) {
    Remove-Item -Recurse -Force .\package
}
New-Item -ItemType Directory -Force -Path .\package | Out-Null

# Instalar dependencias
pip install -r requirements.txt -t .\package

# Copiar el código del bot
Copy-Item .\bot.py .\package\

# Crear el paquete de despliegue
Write-Host "📦 Creando paquete de despliegue..."
if (Test-Path .\deploy_package.zip) {
    Remove-Item -Force .\deploy_package.zip
}
Compress-Archive -Path .\package\* -DestinationPath .\deploy_package.zip -Force

# Limpiar directorio temporal
Remove-Item -Recurse -Force .\package

# Configurar variables para Terraform
Write-Host "🚀 Desplegando en AWS..."
$env:TF_VAR_discord_token = [System.Environment]::GetEnvironmentVariable('DISCORD_TOKEN', 'Process')
$env:TF_VAR_discord_public_key = [System.Environment]::GetEnvironmentVariable('DISCORD_PUBLIC_KEY', 'Process')

# Cambiar al directorio de Terraform
Set-Location terraform

# Inicializar Terraform si es necesario
if (-not (Test-Path .\.terraform)) {
    terraform init
}

# Aplicar la configuración
try {
    terraform apply -auto-approve
    
    # Obtener la URL del API Gateway
    $api_url = terraform output -raw api_endpoint
    
    # Obtener ID de la aplicación de Discord
    $app_id = [System.Environment]::GetEnvironmentVariable('DISCORD_APPLICATION_ID', 'Process')
    
    # Generar el enlace completo por partes para evitar problemas de parseo
    $invite_part1 = "https://discord.com/api/oauth2/authorize?client_id="
    $invite_part2 = "permissions=0"
    $invite_part3 = "scope=bot%20applications.commands"
    
    # Mostrar información
    Write-Host "`n✅ ¡Despliegue completado con éxito!"
    Write-Host "🔗 URL de API Gateway: $api_url"
    Write-Host "`n📝 Configura esta URL como 'Interactions Endpoint URL' en el Portal de Desarrolladores de Discord:"
    Write-Host "   $api_url"
    Write-Host "`n🤖 Invita al bot a un servidor con esta URL:"
    Write-Host "   $invite_part1$app_id&$invite_part2&$invite_part3"
    Write-Host ""
    
} catch {
    Write-Error "Error durante el despliegue: $_"
    exit 1
}
