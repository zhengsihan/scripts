#!/usr/bin/env python3

import shutil
import psutil
from emails import send_email, generate_alarm_email
import socket
import os

# Report an error if CPU usage is over 80%
def check_cpu_usage():
    # CPU usage is over 80%
    usage = psutil.cpu_percent(1)
    return usage > 80

# Report an error if available disk space is lower than 20%
def check_disk_space():
    # Available disk space is lower than 20%
    usage = shutil.disk_usage("/")
    free = usage.free / usage.total * 100
    return free < 20

# Report an error if available memory is less than 500MB
def check_memory_available():
    # available memory is less than 500MB
    info = psutil.virtual_memory()
    return (info.total - info.used)/1024/1024 < 500

# Report an error if the hostname "localhost" cannot be resolved to "127.0.0.1"
def check_localhost():
    # hostname "localhost" cannot be resolved to "127.0.0.1"
    return socket.gethostbyname("localhost") != "127.0.0.1"

# check the system statistics every 60 seconds
# when True, alarm
def check():
    if check_cpu_usage():
        alarm("Error - CPU usage is over 80%")
    if check_disk_space():
        alarm("# Error - Available disk space is less than 20%")
    if check_memory_available():
        alarm("Error - Available memory is less than 500MB")
    if check_localhost():
        alarm("Error - localhost cannot be resolved to 127.0.0.1")

def alarm(msg):
    sender = "automation@example.com"
    recipient = "{}@example.com".format(os.environ.get('USER'))
    body = "Please check your system and resolve the issue as soon as possible."
    msg = generate_alarm_email(sender, recipient, msg, body)
    send_email(msg)

if __name__ == "__main__":
    check()