#! /usr/bin/env python3

import os
import requests
# import json

external_ip = "xx"
data_path = "/data/feedback/"
url = "http://{}/feedback/".format(external_ip)

def read():
    # read file
    file_list = os.listdir(data_path)

    result_list = []
    for file in file_list:
        with open(data_path + file) as f:
            # read line, title, name, date, feedback
            content = f.readlines()
            # envolope to dictionary
            dict = {}
            dict["title"] = content[0]
            dict["name"] = content[1]
            dict["date"] = content[2]
            dict["feedback"] = content[3]
            result_list.append(dict)
            f.close()
    return result_list

    
def send(list):
    for dict in list:
        response = requests.post(url, json=dict)
        if(response.status_code == 200):
            forDEBUG("SEND_SUCC", dict["title"])
        else:
            forDEBUG("SEND_FAIL", dict["title"])

def forDEBUG(p1, p2):
    print("DEBUG::  {},  {}".format(p1, p2))

def action():
    plist = read()
    send(plist)

action()