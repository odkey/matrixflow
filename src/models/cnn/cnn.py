import tensorflow as tf
import sys
import json
from tqdm import tqdm
import inspect
import os
from collections import defaultdict

from ..recipe import Model
from ..recipemanager import Manager as RecipeManager
from ..imagemanager import Manager as ImageManager



class CNN(Model):
    def __init__(self, recipe_id, data_dir="./data"):
        print("init CNN model from recipe_id: ", recipe_id)
        self.data_dir = data_dir
        self.rma = RecipeManager()
        self.ima = ImageManager()
        self.recipe = self.rma.load_recipe(recipe_path=recipe_id)
        self.methods = dict(inspect.getmembers(self, inspect.ismethod))
        self.edge_dict = defaultdict(list)
        print(json.dumps(self.recipe, indent=2))


    def _change_edge_sources(self, id, output):
        for target, source_list in self.edge_dict.items():
            if id in source_list:
                self.edge_dict[target].remove(id)
                self.edge_dict[target].append(output)

    def _generate_edge_dict(self):
        edges = self.recipe["edges"]
        for e in edges:
            source = e["sourceId"]
            target = e["targetId"]
            self.edge_dict[target].append(source)
        print('"target":["source"]')
        print(self.edge_dict)


    def build_nn(self):
        self._generate_edge_dict()
        layers = self.recipe["layers"]
        for layer in layers:
            name = layer["name"]
            id = layer["id"]
            print(name)

            if name == "inputData":
                name = "input_data"
                x_shape = [None, layer["width"], layer["height"]]
                self.x = self.methods[name](x_shape)
                self._change_edge_sources(id, self.x)
            elif name == "inputLabels":
                name = "input_labels"
                y_shape = [None, layer["nClass"]]
                self.y = self.methods[name](y_shape)
                self._change_edge_sources(id, self.y)
            else:
                sources = self.edge_dict[id]
                l = layer
                for h in sources:
                    name = l["name"]
                    if name == "reshape":
                        arg = [h, l["shape"]]
                    elif name == "conv2d":
                        arg = [h, l["outSize"]]
                    elif name == "max_pool":
                        arg = [h]
                    elif name == "flatten":
                        arg = [h]
                    elif name == "fc":
                        arg = [h, l["outSize"], l["act"]]
                    elif name == "loss" or name == "acc":
                        arg = [h]
                    h = self.methods[name](*arg)
                    self._change_edge_sources(id, h)


        #self.x, self.y = self.methods["input"](x_shape, y_shape)
        #h_1 = self.methods["reshape"](self.x, [-1, dim, dim, 1])
        #h_2 = self.conv2d(h_1, out_size=32)
        #h_3 = self.max_pool(h_2)
        #h_4 = self.conv2d(h_3, out_size=64)
        #h_5 = self.max_pool(h_4)
        #h_6 = self.flatten(h_5)
        #h_7 = self.fc(h_6, size=1024)
        #h_8 = self.fc(h_7, size=10, act="ident")

        #self.loss(h_8)
        #self.acc(h_8)

    def train(self, data_path, ws=None):
        self.ima.load_data(os.path.join(self.data_dir, data_path))

        log_dir = "./log"
        if tf.gfile.Exists(log_dir):
            tf.gfile.DeleteRecursively(log_dir)
        tf.gfile.MakeDirs(log_dir)

        config = self.recipe["train"]

        with tf.Graph().as_default():
            print("start session")
            with tf.Session() as sess:
                self.build_nn()
                #summary_writer = tf.summary.FileWriter(log_dir, sess.graph)

                global_step = tf.Variable(0, name="global_step", trainable=False)
                optimizer = tf.train.AdamOptimizer(config["learning_rate"])
                grads_and_vars = optimizer.compute_gradients(self.loss)
                train_op = optimizer.apply_gradients(grads_and_vars, global_step=global_step)

                sess.run(tf.global_variables_initializer())
                epoch = config["epoch"]
                batch_size = config["batch_size"]
                n_iter = int(epoch * self.ima.n_train)
                for i in tqdm(range(n_iter)):

                    if ws:
                        res = {"action": "learning", "iter": i, "nIter": n_iter}
                        ws.send(json.dumps(res))

                    labels, images = self.ima.next_batch("train", batch_size)
                    sess.run(train_op, feed_dict={self.x: images, self.y: labels})
                    if i % config["saver"]["evaluate_every"] == 0:
                        train_loss, train_accuracy = sess.run(
                                                        [self.loss, self.accuracy],
                                                        feed_dict={self.x: images, self.y: labels})
                        print('step %d, training loss %g, training accuracy %g' % (i, train_loss, train_accuracy))
                        if ws:
                            res = {
                                "action": "evaluate_train",
                                "iter": i,
                                "nIter": n_iter,
                                "loss": str(train_loss),
                                "accuracy": str(train_accuracy)
                            }
                            ws.send(json.dumps(res))

                    if i % 50 == 0 and i != 0:
                        labels, images = self.ima.next_batch("test", self.ima.n_test)
                        feed = {self.x: images, self.y: labels}
                        test_loss, test_accuracy = sess.run([self.loss, self.accuracy], feed_dict=feed)
                        print('step %d, test loss %g, test accuracy %g' % (i, test_loss, test_accuracy))
                        if ws:
                            res = {
                                "action": "evaluate_test",
                                "iter": i,
                                "nIter": n_iter,
                                "loss": str(test_loss),
                                "accuracy": str(test_accuracy)
                            }
                            ws.send(json.dumps(res))
