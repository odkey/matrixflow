# -*- coding: utf-8 -*-
import cv2
import os
from filemanager import get_save_path
from log import log_debug

def get_facerect(CVimage):
    #cascade_path = '/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml'
    cascade_path = '/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt2.xml'
    cascade = cv2.CascadeClassifier(cascade_path)
    image_gray = cv2.cvtColor(CVimage, cv2.COLOR_BGR2GRAY)
    facerect = cascade.detectMultiScale(image_gray, scaleFactor=1.2, minNeighbors=2, minSize=(10, 10))
    return facerect


def circumscribe_face(image_path, image_name, dist_path, image_number=None):
    image = cv2.imread(image_path+"/"+image_name)
    facerect = get_facerect(image)
    if len(facerect) <= 0:
        return {
            "status": "error",
            "code": 1,
            "http_status": 400
        }
    num = 0
    for rect in facerect:
        color = (255, 255, 255)
        if num == image_number:
            color = (0, 0, 255) # red
        cv2.rectangle(image, tuple(rect[0:2]),
                tuple(rect[0:2] + rect[2:4]), color, thickness=2)
        num +=1
    new_rect_path = dist_path + '/' +'rect_' + image_name;
    cv2.imwrite(new_rect_path, image)
    return {"status":"success","data_type":"detail","detail":{"number":num}}

def cutout_face(image_path, image_name, dist_path):
    image = cv2.imread(image_path+"/"+image_name)
    facerect = get_facerect(image)
    if len(facerect) <= 0:
        return {
            "status": "error",
            "code": 1,
            "http_status": 400
        }
    for i,rect in enumerate(facerect):
        x = rect[0]
        y = rect[1]
        width = rect[2]
        height = rect[3]
        dst = image[y:y+height, x:x+width]
        new_image_path = dist_path + '/' + 'face_'+ str(i) + "_"+image_name;
        cv2.imwrite(new_image_path, dst)
    num = i+1
    return {"status":"success","data_type":"detail","detail":{"number":num}}

def get_face_image_name(image_id, type="face", number=0, full_path=True):
    u"""

    return: fullpath name
    """
    prefix = type + "_" + (str(number)+"_" if type== "face" else "")
    path = get_save_path(image_id)
    if path:
        image_list = os.listdir(path)
        for img in image_list:
            if prefix in img:
                name = img
                break
        else:
            return None
        if full_path:
            return os.path.join(path,name)
        else:
            return name
    else:
        return None
