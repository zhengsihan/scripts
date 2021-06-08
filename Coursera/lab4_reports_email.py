#!/usr/bin/env python3

from reportlab.platypus import Paragraph, SimpleDocTemplate,Table
from reportlab.lib.styles import getSampleStyleSheet
import os
import time
from reports import generate_report
from emails import generate_email, send_email

def gen_report():
    user = os.environ.get('USER')
    path = "/home/" + user
    desc_path = path + "/supplier-data/descriptions/"
    g = os.walk(desc_path)
    pdf_path = "/tmp/processed.pdf"
    table_content = []
    for path, dir_list, file_list in g:
        for file in file_list:
            with open(desc_path + file) as f:
                rows = f.readlines()
                name = rows[0].strip()
                weight = rows[1].strip()
                table_content.append("name: {}".format(name))
                table_content.append("weight: {}".format(weight))
                table_content.append("")
                f.close()
    
    title = "Processed Update on {}".format(time.strftime("%b %d, %Y", time.localtime()))

    i = 0
    body_detail = ""
    for item in table_content:
        if i == 0:
            body_detail += item + "<br/>"
            i += 1
        if i >= 1:
            body_detail += item + "<br/><br/>"
            i = 0

    generate_report(pdf_path, title, body_detail)

def send():
    sender = "automation@example.com"
    recipient = "{}@example.com".format(os.environ.get('USER'))
    subject = "Upload Completed - Online Fruit Store"
    body = "All fruits are uploaded to our website successfully. A detailed list is attached to this email."
    attachment_path = "/tmp/processed.pdf"
    msg = generate_email(sender, recipient, subject, body, attachment_path)
    send_email(msg)

if __name__ == "__main__":
    gen_report()
    send()