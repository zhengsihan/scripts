#!/usr/bin/env python3

from PIL import Image
import os


def changeImage():
    user = os.environ.get('USER')
    path = "/home/" + user
    old_path = path + "/supplier-data/images"
    new_path = old_path
    g = os.walk(old_path)
    for path, dir_list, file_list in g:
        for file in file_list:
            if file[-5:] == ".tiff":
                # Open an image
                im = Image.open(os.path.join(path, file))
                im = im.convert("RGB")
                # Size: Change image resolution from 3000x2000 to 600x400 pixel
                new_im = im.resize((600, 400))
                # Format: Change image format from .TIFF to .JPEG
                new_im.save("{}/{}".format(new_path, file[0:-5] + ".jpeg"), "JPEG")
    
changeImage()