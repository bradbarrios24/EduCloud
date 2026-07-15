import json
import os
import boto3

ses_client = boto3.client("ses")

SENDER = os.environ.get("SES_SENDER", "no-reply@example.com")


def handler(event, context):
    """
    Procesa mensajes de SQS y envia un correo via SES por cada uno.
    """
    for record in event.get("Records", []):
        body = record.get("body", "{}")

        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            payload = {"mensaje": body}

        destinatario = payload.get("email")
        asunto = payload.get("asunto", "Notificacion EduCloud")
        contenido = payload.get("mensaje", "Sin contenido")

        if not destinatario:
            print(f"Registro sin email de destino, se omite: {payload}")
            continue

        ses_client.send_email(
            Source=SENDER,
            Destination={"ToAddresses": [destinatario]},
            Message={
                "Subject": {"Data": asunto},
                "Body": {"Text": {"Data": contenido}},
            },
        )

        print(f"Correo enviado a {destinatario}")

    return {"statusCode": 200, "body": "OK"}