import os
import json
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda handler function for Discord interactions.
    For simplicity, we'll skip the signature verification for now.
    """
    # Log detailed information for diagnostics
    logging.info(f"Received event: {event}")
    logging.info(f"Headers: {event.get('headers', {})}")
    
    # Get Discord headers for verification
    headers = event.get('headers', {})
    
    # Discord puede enviar headers en minúsculas o mayúsculas, buscamos ambos
    signature = headers.get('X-Signature-Ed25519', headers.get('x-signature-ed25519', ''))
    timestamp = headers.get('X-Signature-Timestamp', headers.get('x-signature-timestamp', ''))
    
    # Log para depuración
    logging.info(f"Signature: {signature}")
    logging.info(f"Timestamp: {timestamp}")
    
    # Parse the request body
    try:
        body = event['body']
        
        # Para simplificar, omitimos la verificación de firma por ahora
        # En producción, deberías implementar la verificación de firma ED25519
        logging.info("Skipping signature verification for testing purposes")
        
        # Parse the body as JSON
        body_json = json.loads(body)
        
        # Check if it's a ping interaction (type 1)
        if body_json.get('type') == 1:
            logging.info("Received PING from Discord - responding with PONG")
            return {
                'statusCode': 200,
                'body': json.dumps({'type': 1})
            }
        
        # Handle APPLICATION_COMMAND interaction (type 2)
        elif body_json.get('type') == 2:
            logging.info(f"Received command interaction: {body_json}")
            
            # Get the command name
            command_name = body_json.get('data', {}).get('name')
            logging.info(f"Command name: {command_name}")
            
            # Handle different commands
            if command_name == 'hello':
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                        'data': {
                            'content': '¡Hola! Soy TerraBot, tu asistente serverless.'
                        }
                    })
                }
            elif command_name == 'info':
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                        'data': {
                            'content': 'TerraBot v2.0 - Desplegado en AWS Lambda con Terraform'
                        }
                    })
                }
            else:
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                        'data': {
                            'content': f'Comando `{command_name}` no reconocido.'
                        }
                    })
                }
        
        # Handle MESSAGE_COMPONENT interaction (type 3)
        elif body_json.get('type') == 3:
            logging.info(f"Received component interaction: {body_json}")
            custom_id = body_json.get('data', {}).get('custom_id', '')
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                    'data': {
                        'content': f'Interacción con componente `{custom_id}` recibida.'
                    }
                })
            }
        
        # Default response for unhandled interaction types
        return {
            'statusCode': 200,
            'body': json.dumps({
                'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                'data': {
                    'content': 'Tipo de interacción no soportado.'
                }
            })
        }
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
