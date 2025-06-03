import os
import json
import requests
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv()

# Obtener token y application_id desde variables de entorno
TOKEN = os.getenv('DISCORD_TOKEN')
APPLICATION_ID = os.getenv('DISCORD_APPLICATION_ID')

# URL base para la API de Discord
BASE_URL = f"https://discord.com/api/v10/applications/{APPLICATION_ID}/commands"

# Headers para la autenticación
headers = {
    "Authorization": f"Bot {TOKEN}",
    "Content-Type": "application/json"
}

# Definir los comandos que queremos registrar
commands = [
    {
        "name": "hello",
        "description": "Saludo del bot",
        "type": 1
    },
    {
        "name": "info",
        "description": "Muestra información sobre el bot",
        "type": 1
    }
]

def register_commands():
    """Registra los comandos en Discord"""
    print(f"Registrando {len(commands)} comandos para la aplicación {APPLICATION_ID}...")
    
    # Registrar cada comando
    for command in commands:
        print(f"Registrando comando: {command['name']}")
        response = requests.post(BASE_URL, headers=headers, json=command)
        
        if response.status_code == 200 or response.status_code == 201:
            print(f"[OK] Comando '{command['name']}' registrado correctamente")
        else:
            print(f"[ERROR] Error al registrar el comando '{command['name']}': {response.status_code}")
            print(response.text)

if __name__ == "__main__":
    if not TOKEN or not APPLICATION_ID:
        print("Error: Asegúrate de que DISCORD_TOKEN y DISCORD_APPLICATION_ID estén definidos en el archivo .env")
    else:
        register_commands()
