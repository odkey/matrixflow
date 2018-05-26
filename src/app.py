from bottle import request, Bottle, run, template

import json
import os
import sys

#sys.path.append(os.getcwd() + '/domain')

from response import put_response
from log import log_debug
from getface import cutout_face, get_face_image_name, circumscribe_face
#from prob import Prob
import filemanager as fm
#html_path = "../static/html/"

from gevent.pywsgi import WSGIServer
import gevent
from geventwebsocket import WebSocketError
from geventwebsocket.handler import WebSocketHandler
from multiprocessing import Process
from models.cnn.cnn import CNN



app = Bottle()
dictionary = {}
#prob = Prob()
fm.create_save_dir()

@app.route('/')
def index_html():
    #return template("index")
    return template("index_ws")

@app.route('/recipes', method="GET")
def get_recipes_list():
    offset = request.params.get("offset", 0)
    limit = request.params.get("limit")
    res = fm.get_recipe_list(offset, limit)
    return put_response(res)

@app.route('/recipes', method="POST")
def add_recipe():
    content_type = request.get_header('Content-Type')
    if content_type == "application/json":
        obj = request.json
        res = fm.save_recipe(obj)
    else:
        res = {"status": "error"}
    return put_response(res)

@app.route('/recipes/<recipe_id>', method="GET")
def get_recipe(recipe_id):
    res = fm.get_recipe(recipe_id)
    return put_response(res)

@app.route('/recipes/<recipe_id>', method="PUT")
def update_recipe(recipe_id):
    content_type = request.get_header('Content-Type')
    if content_type == "application/json":
        obj = request.json
        res = fm.update_recipe(recipe_id, obj)
    else:
        res = {"status": "error"}
    return put_response(res)

@app.route('/recipes/<recipe_id>', method="DELETE")
def delete_recipe(recipe_id):
    res = fm.delete_recipe(recipe_id)
    return put_response(res)



def handler(wsock, message):
    d = dictionary[wsock]
    try:
        obj = json.loads(message)
        print(obj)
        if obj["action"] == "upload":
            pass
        elif obj["action"] == "get_recipe_list":
            offset = obj.get("offset", 0)
            limit = obj.get("limit")
            res = fm.get_recipe_list(offset, limit)
            res["action"] = "get_recipe_list"
            wsock.send(json.dumps(res))
        elif obj["action"] == "start_learing":
            recipe_id = obj["recipeId"]
            data_id = obj["dataId"]
            model = CNN(recipe_id)
            model.train(data_id, wsock)




    except (UnicodeDecodeError, json.decoder.JSONDecodeError):
        d["size"] += len(message)
        d["uploading_file"] += message
        response = {"status": "loading", "loadedSize": d["size"]}
        print(response)
        wsock.send(json.dumps(response))
        if d["size"] == int(d["file_size"]):
            uploading_file = d["uploading_file"]
            file_id = put_upload_file(uploading_file)
            response = {"status": "loaded", "fileId": file_id}
            wsock.send(json.dumps(response))


@app.route('/connect')
def handle_websocket():
    wsock = request.environ.get('wsgi.websocket')
    if not wsock:
        abort(400, 'Expected WebSocket request.')
    global dictionary

    if wsock not in dictionary:
        dictionary[wsock] = {
            "num": None,
            "file_size": 0,
            "size": 0,
            "uploading_file": bytearray()
        }

    while True:
        try:
            message = wsock.receive()
            gevent.spawn(handler, wsock, message)
        except WebSocketError:
            break








@app.route('/upload', method="POST")
def upload_file():
    files = request.files
    res = fm.upload_file(files)
    if res["status"] == "success":
        name = res["detail"]["name"]
        id = res["detail"]["id"]
        save_path = fm.get_save_path(id)
        cutout_res = cutout_face(save_path,name,save_path)
        if cutout_res["status"] == "error":
            return put_response(cutout_res)
        else:
            res["detail"]["faceTotal"] = cutout_res["detail"]["number"]
        circum_res = circumscribe_face(save_path,name,save_path)
        if circum_res["status"] == "error":
            return put_response(circum_res)
    print(res)
    return put_response(res)

@app.route('/images/<image_id>/face/<number>', method="GET")
def get_face(image_id, number):
    fullpath = get_face_image_name(image_id, number)
    with open(fullpath) as f:
        image = f.read()
    content_type = fm.get_content_type(fullpath)
    return put_response(image, content_type=content_type)

@app.route('/images/<image_id>/rectangle', method="GET")
def get_rectangle(image_id):
    fullpath = get_face_image_name(image_id,type="rect")
    with open(fullpath) as f:
        image = f.read()
    content_type = fm.get_content_type(fullpath)
    return put_response(image, content_type=content_type)

@app.route('/images/<image_id>/rectangle/indiviual/<number>', method="GET")
def get_rectangle_indiviual(image_id, number):
    name = get_face_image_name(image_id, type="rect", full_path=False)
    save_path = fm.get_save_path(image_id)
    res = circumscribe_face(save_path, name[5:], save_path, int(number))
    fullpath = save_path + "/" + name;
    with open(fullpath) as f:
        image = f.read()
    content_type = fm.get_content_type(fullpath)
    return put_response(image, content_type=content_type)

@app.route('/images/<image_id>/probability', method="GET")
def get_probability(image_id):
    res = prob.get_prob(image_id)
    return put_response(res)

@app.route('/static/<file_type>/<file>')
def read_static(file_type, file):
    if file_type == "js":
        content_type = "text/javascript"
    elif file_type == "css":
        content_type = "text/css"
    else:
        content_type = "text/html"
    with open('../static/'+file_type+'/'+file) as f:
        data = f.read()
    return put_response(data=data, content_type=content_type)

if __name__ == '__main__':
    #app.run(host="0.0.0.0", port=8081, debug=True, reloader=True)
    server = WSGIServer(("0.0.0.0", 8081), app, handler_class=WebSocketHandler)
    server.serve_forever()
