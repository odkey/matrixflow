# -*- coding: utf-8 -*-
from bottle import response, HTTPResponse
import json


def put_response(data, status=200, content_type="application/json"):
    if "image/" in content_type or \
        content_type == "text/javascript" or \
        content_type == "text/css":

        data = data
        res = HTTPResponse(body=data, status=status)
        res.set_header('Content-Type', content_type)
        res.set_header('Access-Control-Allow-Origin', '*')
    elif data["status"] == "error":
        if status == 200:
            status = 500
        if "http_status" in data and data["http_status"]:
            status = data["http_status"]
        with open("../etc/errorMapping.json","r") as f:
            mapping_json = json.load(f)
            if "code" in data:
                code = data["code"]
            else:
                code = 0
            message = mapping_json[str(code)]
        body = {"error":{"message": message, "code":code}}
        res = HTTPResponse(body=body, status=status)
        res.set_header('Content-Type', 'application/json')
        res.set_header('Access-Control-Allow-Origin', '*')
    else:
        if isinstance(data, dict):
            if data["data_type"] == "detail":
                data = json.dumps(data["detail"])
            else:
                data = json.dumps(data["list"])
        else:
            data = {}
        res = HTTPResponse(body=data, status=status)
        res.set_header('Content-Type', content_type)
        res.set_header('Access-Control-Allow-Origin', '*')
    return res
