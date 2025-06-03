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
        # Aquí simplemente registramos que estamos omitiendo la verificación
        logging.info("Skipping signature verification for testing purposes")
        
        # Parse the body as JSON
        body_json = json.loads(body)
        
        # Handle Discord PING (type 1)
        if body_json.get('type') == 1:
            logging.info("Received PING from Discord - responding with PONG")
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'type': 1})  # PONG response
            }
        
        # Handle application commands (type 2)
        if body_json.get('type') == 2:
            command_name = body_json.get('data', {}).get('name', '')
            logging.info(f"Received command: {command_name}")
            
            # Handle ping command
            if command_name == 'ping':
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json'
                    },
                    'body': json.dumps({
                        'type': 4,  # CHANNEL_MESSAGE_WITH_SOURCE
                        'data': {
                            'content': 'Pong! 🏓'
                        }
                    })
                }
            
            # Default response for other commands
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'type': 4,
                    'data': {
                        'content': f'Command received: {command_name}'
                    }
                })
            }
        
        # Default response for other interaction types
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'message': 'Event processed successfully'})
        }
        
    except Exception as e:
        logging.error(f'Error processing event: {e}')
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }
