
# -*- coding: utf-8 -*-

import os
import shutil
import hashlib

def upload_file(files):
    allow_file = ["jpeg","png","jpg","JPEG","JPG","PNG"]
    u"""
    upload file (non multiple finles)

    """
    id = ""
    for name, file in files.items():
        error_res = {
            "status": "error",
            "http_status": 400,
            "code": 3
        }
        try:
            ext = name.split(".")[-1]
            if not ext in allow_file:
                return error_res
        except:
            return error_res

        f = file.file.read()
        id = hashlib.md5(f).hexdigest()
        save_path = get_save_path(id)
        remove_save_path(id)
        os.mkdir(save_path)
        file.file.seek(0)
        file.save(save_path)
    if id:
        res = {
            "status":"success",
            "data_type": "detail",
            "detail": {"id": id, "name": name}
        }
    else:
        res = {
            "status": "error",
            "http_status": 500,
            "code": 2
        }
    return res

def create_save_dir(path="var/tmp"):
    abs_path = os.path.join(os.getcwd(),path)
    if not os.path.exists(abs_path):
        os.makedirs(abs_path)


def get_save_path(id):
    save_path = os.path.join(os.getcwd(), "var/tmp", id)
    return save_path

def remove_save_path(id):
    save_path = get_save_path(id)
    if os.path.isdir(save_path):
        shutil.rmtree(save_path)

def get_content_type(name):
    ext = name.split(".")[-1].lower()
    if ext == "jpg":
        ext = "jpeg"
    content_type = "image/"+ext
    return content_type
