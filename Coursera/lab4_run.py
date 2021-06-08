#!/usr/bin/env python3

import os
import requests
import json

def upload_desc():
    external_ip = "104.154.103.197"
    user = os.environ.get('USER')
    path = "/home/" + user
    desc_path = path + "/supplier-data/descriptions/"
    g = os.walk(desc_path)
    url = "http://{}/fruits/".format(external_ip)
    for path, dir_list, file_list in g:
        for file in file_list:
            if file[-4:] == ".txt":
                with open(desc_path + file) as f:
                    # The description have: name, weight, description
                    # The endpoint required: name, weight, description and image_name
                    rows = f.readlines()
                    name = rows[0].strip()
                    weight = rows[1].strip()
                    desc = rows[2].strip()
                    img_name = file.replace(".txt", ".jpeg")
                    dict = {}
                    dict["name"] = name
                    dict["weight"] = int(weight.replace("lbs","").strip())
                    dict["description"] = desc
                    dict["image_name"] = img_name
                    response = requests.post(url, json=dict)
                    if response.status_code >= 200 and response.status_code < 300:
                        print("{} :: {} upload SUCC!".format(file, response.status_code))
                    else:
                        print("{} :: {} upload FAIL!".format(file, response.status_code))
                    f.close()

upload_desc()