#!/usr/bin/env python3

from PIL import Image
import os

#瑕疵：.DS_STORE不能排除
def pic_opt():
    #原图片地址
    dir = "/home/student-01-b4eb7aef71c2/images"
    new_path = "/opt/icons/"

    g = os.walk(dir)

    for path, dir_list, file_list in g:
        for pic in file_list:
            # Open an image
            im = Image.open(os.path.join(path, pic))

            # Rotate an image
            im.rotate(90)

            # Resize an image
            new_im = im.resize((128, 128))

            #for exception : cannot write mode P as JPEG
            im = im.convert("RGB")

            # Save an image in a specific format in a separate directory
            new_im.save("{}/{}".format(new_path, pic), "JPEG")

pic_opt()
