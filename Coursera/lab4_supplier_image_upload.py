#!/usr/bin/env python3
import requests
import os

def upload():
    upload_url = "http://localhost/upload/"
    user = os.environ.get('USER')
    path = "/home/" + user
    image_path = path + "/supplier-data/images"
    g = os.walk(image_path)
    for path, dir_list, file_list in g:
        for file in file_list:
            if file[-5:] == ".jpeg":
                with open(image_path + "/" + file, 'rb') as opened:
                    r = requests.post(upload_url, files={'file': opened})

upload()