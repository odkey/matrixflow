import os
import shutil
import hashlib
import datetime
import json
from pathlib import Path

recipe_dir = "./recipes"
data_dir = "./data"

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


def get_data_list():
    p = Path(data_dir)
    p_list = [x for x in p.iterdir() if x.is_dir()]
    print(p_list)
    length = len(p_list)
    data = []
    for j in p_list:
        images = j / "images"
        labels = j / "labels" / "labels.csv"
        info = j / "info" / "info.json"
        id = j.name
        n_images = len(list(images.glob("*")))
        print(n_images)
        print(images, labels, info)
        with open(info, "r") as f:
            body = json.load(f)

        with open(labels, "r") as f:
            n_labels = len(f.readlines())

        epoch_time = os.path.getctime(j)
        create_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")

        epoch_time = os.path.getmtime(j)
        update_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")
        rec = {
            "id": id,
            "nImages": n_images,
            "nLabels": n_labels,
            "name": body.get("name", ""),
            "description": body.get("description", ""),
            "update_time": update_time,
            "create_time": create_time
        }
        data.append(rec)
    res = {
            "status": "success",
            "data_type": "list",
            "total": length,
            "list": data
    }
    return res



def save_recipe(obj):
    dir_name = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    dir_path = os.path.join(recipe_dir, dir_name)
    create_save_dir(dir_path)
    file_path = os.path.join(dir_path, "recipe.json")
    with open(file_path, "w") as f:
        json.dump(obj, f, indent=2)
    res = {
        "status": "success",
        "data_type": "detail",
        "detail": {"id": dir_name, "body": obj}
    }
    return res

def get_recipe_list(offset=0, limit=None):
    offset = int(offset)
    recipes = []
    p = Path(recipe_dir)
    p_list = list(p.glob("*/*.json"))
    length = len(p_list)
    if limit is not None:
        limit = int(limit)
        p_list = p_list[offset:limit]
    else:
        p_list = p_list[offset:]
    for j in p_list:
        id = j.parent.name
        with open(j, "r") as f:
            body = json.load(f)

        epoch_time = os.path.getctime(j)
        create_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")

        epoch_time = os.path.getmtime(j)
        update_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")
        rec = {
            "id": id,
            "body": body,
            "update_time": update_time,
            "create_time": create_time
        }
        recipes.append(rec)
    res = {
            "status": "success",
            "data_type": "list",
            "total": length,
            "list": recipes
        }
    return res

def get_recipe(id):
    p = Path(recipe_dir) / id / "recipe.json"
    with open(p, "r") as f:
        body = json.load(f)
    recipe = {"id": id, "body": body}
    res = {
        "status": "success",
        "data_type": "detail",
        "detail": recipe
    }
    return res

def update_recipe(id, obj):
    p = Path(recipe_dir) / id / "recipe.json"
    with open(p, "w") as f:
        json.dump(obj, f, indent=2)
    res = {
        "status": "success",
        "data_type": "detail",
        "detail": {"id": id, "body": obj}
    }
    return res

def delete_recipe(id):
    p = Path(recipe_dir) / id
    if os.path.isdir(p):
        shutil.rmtree(p)
    res = {
        "status": "success",
        "data_type": "delete"
    }
    return res
