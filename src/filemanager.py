import os
import shutil
import hashlib
import datetime
import json
import zipfile
from pathlib import Path

recipe_dir = "./recipes"
data_dir = "./data"
model_dir = "./logs"

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

def generate_id():
    """
     generate ids which are same as file paths.
    """
    return datetime.datetime.now().strftime("%Y%m%d%H%M%S")

def save_json(obj, file_path):
    with open(file_path, "w") as f:
        json.dump(obj, f, indent=2)



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

def put_zip_file(file, file_id, is_expanding=False):
    """
      file: bitearray
      file_id: string
    """
    p = Path(data_dir) / file_id
    os.makedirs(p, exist_ok=True)
    file_path = p / "image.zip"
    with open(file_path, "wb") as f:
        f.write(file)

    if is_expanding:
        image_path = p
        with zipfile.ZipFile(file_path) as existing_zip:
            try:
                existing_zip.extractall(image_path)
            except Exception as e:
                os.remove(file_path)
                print(e)
                return {"status": "error"}
        os.remove(file_path)
    return {"status": "success"}

def put_data_info(new_data, file_id):
    p = Path(data_dir) / file_id
    info_path = p / "info"
    os.makedirs(info_path, exist_ok=True)
    file_path = info_path / "info.json"
    save_json(new_data, file_path)
    return get_data(p)

def get_model_info(model_id):
    p = Path(model_dir) / model_id / "info" / "info.json"
    with open(p, "r") as f:
        body = json.load(f)
    body["id"] = model_id
    body["create_time"] = get_create_time(p)
    body["update_time"] = get_update_time(p)
    res = {
        "status": "success",
        "data_type": "detail",
        "detail": body
    }
    return res


def put_model_info(new_model, model_id):
    info_dir = Path(model_dir) / model_id / "info"
    os.makedirs(info_dir, exist_ok=True)
    info_path = info_dir / "info.json"
    save_json(new_model, info_path)
    return get_model_info(model_id)

def get_create_time(p):
    """
    p Path object
    """
    epoch_time = os.path.getctime(p)
    create_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")
    return create_time

def get_update_time(p):
    """
    p Path object
    """
    epoch_time = os.path.getmtime(p)
    update_time = datetime.datetime.fromtimestamp(epoch_time).strftime("%Y-%m-%d %H:%M:%S")
    return update_time

def get_model_list():
    p = Path(model_dir)
    p_list = [x for x in p.iterdir() if x.is_dir()]
    length = len(p_list)
    models = []
    for j in p_list:
        id = j.name
        info = j / "info" / "info.json"
        if info.exists():
            with open(info, "r") as f:
                body = json.load(f)
            update_time = get_update_time(info)
        else:
            body = {}
            update_time = get_update_time(j)

        create_time = get_create_time(j)
        model = {
            "id": id,
            "name": body.get("name", ""),
            "description": body.get("description", ""),
            "update_time": update_time,
            "create_time": create_time
        }
        models.append(model)
    res = {
            "status": "success",
            "data_type": "list",
            "total": length,
            "list": models
    }
    return res


def get_data(path):
    images = path / "images"
    labels = path / "labels" / "labels.csv"
    info = path / "info" / "info.json"
    id = path.name
    n_images = len(list(images.glob("*")))
    print(n_images)
    print(images, labels, info)
    if info.exists():
        with open(info, "r") as f:
            body = json.load(f)
    else:
        body = {}

    if labels.exists():
        with open(labels, "r") as f:
            n_labels = len(f.readlines())
    else:
        n_labels = 0

    create_time = get_create_time(path)
    update_time = get_update_time(info)
    data = {
        "id": id,
        "nImages": n_images,
        "nLabels": n_labels,
        "name": body.get("name", ""),
        "description": body.get("description", ""),
        "update_time": update_time,
        "create_time": create_time
    }
    return data

def get_data_list():
    p = Path(data_dir)
    p_list = [x for x in p.iterdir() if x.is_dir()]
    length = len(p_list)
    data = []
    for path in p_list:
        d = get_data(path)
        data.append(d)
    res = {
            "status": "success",
            "data_type": "list",
            "total": length,
            "list": data
    }
    return res

def delete_data(id):
    p = Path(data_dir) / id
    if os.path.isdir(p):
        shutil.rmtree(p)
    res = {
        "status": "success",
        "data_type": "delete"
    }
    return res



def save_recipe(obj):
    dir_name = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    dir_path = os.path.join(recipe_dir, dir_name)
    create_save_dir(dir_path)
    file_path = os.path.join(dir_path, "recipe.json")
    save_json(obj, file_path)
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

        create_time = get_create_time(j)
        update_time = get_update_time(j)
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
    create_time = get_create_time(p)
    update_time = get_update_time(p)
    recipe = {
        "id": id,
        "body": body,
        "update_time": update_time,
        "create_time": create_time
    }
    res = {
        "status": "success",
        "data_type": "detail",
        "detail": recipe
    }
    return res

def update_recipe(id, obj):
    p = Path(recipe_dir) / id / "recipe.json"
    save_json(obj, p)
    return get_recipe(id)

def delete_recipe(id):
    p = Path(recipe_dir) / id
    if os.path.isdir(p):
        shutil.rmtree(p)
    res = {
        "status": "success",
        "data_type": "delete"
    }
    return res


def delete_model(id):
    p = Path(model_dir) / id
    if os.path.isdir(p):
        shutil.rmtree(p)
    res = {
        "status": "success",
        "data_type": "delete"
    }
    return res
