terraform {
  backend "s3" {
    # Bucket S3 para almacenar el estado de Terraform
    bucket         = "terrabot-tf-state-adalia"
    
    # Ruta donde se guardará el archivo de estado dentro del bucket
    key            = "terraform/terraform.tfstate"
    
    # Región donde está ubicado tu bucket S3
    region         = "us-east-1"
    
    # Habilitar cifrado del estado
    encrypt        = true
    
    # Tabla de DynamoDB para bloqueo de estado
    dynamodb_table = "terraform-locks"
  }
}

# Nota: Las credenciales de AWS deben configurarse mediante variables de entorno o el archivo de credenciales de AWS.
