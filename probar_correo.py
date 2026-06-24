import os
import smtplib
from email.message import EmailMessage


sender = os.getenv("EMAIL_HOST_USER")
password = os.getenv("EMAIL_HOST_PASSWORD")
recipient = sender

if not sender or not password:
    raise SystemExit("Falta configurar EMAIL_HOST_USER o EMAIL_HOST_PASSWORD en email_config.bat")

msg = EmailMessage()
msg["Subject"] = "Prueba Restaurante Contab"
msg["From"] = sender
msg["To"] = recipient
msg.set_content("Correo de prueba enviado desde Restaurante Contab.")

with smtplib.SMTP("smtp.gmail.com", 587, timeout=20) as smtp:
    smtp.ehlo()
    smtp.starttls()
    smtp.ehlo()
    smtp.login(sender, password)
    smtp.send_message(msg)

print("Correo enviado correctamente a", recipient)

