#!/usr/bin/env python3

from emails import generate_email, send_email
import os

def action():
    sender = "automation@example.com"
    recipient = "{}@example.com".format(os.environ.get('USER'))
    subject = "Upload Completed - Online Fruit Store"
    body = "All fruits are uploaded to our website successfully. A detailed list is attached to this email."
    attachment_path = "/tmp/processed.pdf"
    msg = generate_email(sender, recipient, subject, body, attachment_path)
    send_email(msg)

if __name__ == "__main__":
    action()