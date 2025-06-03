import os
import json
import logging
import nacl.exceptions
from nacl.signing import VerifyKey

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda handler function with proper ED25519 signature verification.
    """
    # Log detailed information for diagnostics
    logging.info(f"Received event: {event}")
    logging.info(f"Headers: {event.get('headers', {})}")
    
    # Get Discord headers for verification
    headers = event.get('headers', {})
    signature = headers.get('X-Signature-Ed25519', '')
    timestamp = headers.get('X-Signature-Timestamp', '')
    
    # Get Discord public key from environment variables
    verify_key = os.environ.get('DISCORD_PUBLIC_KEY', '')
    
    # Parse the request body
    try:
        body = event['body']
        
        # Verify the signature if we're not in debug mode
        # For verification ping, we need to validate the signature
        try:
            verify_key_bytes = bytes.fromhex(verify_key)
            signature_bytes = bytes.fromhex(signature)
            message = timestamp.encode() + body.encode()
            
            # Create the verify key from the public key
            discord_verify_key = VerifyKey(verify_key_bytes)
            
            # Verify the signature
            discord_verify_key.verify(message, signature_bytes)
            logging.info("Signature verification successful")
        except (nacl.exceptions.BadSignatureError, ValueError) as e:
            logging.error(f"Signature verification failed: {e}")
            return {
                'statusCode': 401,
                'body': json.dumps({'error': 'Invalid request signature'})
            }
        
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
