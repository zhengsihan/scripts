#!/usr/bin/env python3

from reportlab.platypus import Paragraph, SimpleDocTemplate,Table, Spacer
from reportlab.lib.styles import getSampleStyleSheet
import time

def generate_report(attachment, title, content):
    styles = getSampleStyleSheet()
    report_title = Paragraph(title, styles["h1"])
    report = SimpleDocTemplate(attachment)
    body = Paragraph(content, styles["BodyText"])
    report.build([report_title, Spacer(1,20), body])