#!/usr/bin/env python3
import sys
import subprocess

def change():
    with open("oldFiles.txt", "r") as f:
        for line in f:
            prefix = '/home/student-04-ad8824a8c895'
            oldName = prefix + line.strip()
            newName = prefix + line.strip().replace('jane', 'jdoe')
            subprocess.run(["mv", oldName, newName])
        f.close()

change()