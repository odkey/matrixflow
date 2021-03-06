import tensorflow as tf
import sys
import json
from tqdm import tqdm
import inspect
import os
from collections import defaultdict
import datetime
import networkx as nx

sys.path.insert(0, '../..')
from ..recipe import Model
from ..recipemanager import Manager as RecipeManager
from ..imagemanager import Manager as ImageManager
from filemanager import put_model_info

out_dir = "logs"
save_checkpoint = True
os.makedirs(out_dir, exist_ok=True)



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
        self.id = None
        self.out_dir = None


    def _change_edge_sources(self, id, output):
        for target, source_list in self.edge_dict.items():
            if id in source_list:
                self.edge_dict[target].remove(id)
                self.edge_dict[target].append(output)
        #print(self.edge_dict)

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
        edges = self.recipe["edges"]
        ed = [(e["sourceId"], e["targetId"]) for e in edges]
        G = nx.DiGraph()
        G.add_edges_from(ed)
        sorted_edges = list(nx.topological_sort(G))
        layers_dict = { layer["id"]: layer for layer in layers}

        for layer_id in sorted_edges:
            layer = layers_dict[layer_id]
            name = layer["name"]
            id = layer["id"]
            print(name)
            if "params" in layer:
                params = layer["params"]

            if name == "inputData":
                name = "input_data"
                x_shape = [None, params["dataWidth"], params["dataHeight"]]
                self.x = self.methods[name](x_shape)
                self._change_edge_sources(id, self.x)
            elif name == "inputLabels":
                name = "input_labels"
                y_shape = [None, params["nClass"]]
                self.y = self.methods[name](y_shape)
                self._change_edge_sources(id, self.y)
            elif name == "loss" or name == "acc":
                sources = self.edge_dict[id]
                arg = sources
                h = self.methods[name](*arg)
                self._change_edge_sources(id, h)
            else:
                sources = self.edge_dict[id]
                h = sources[0]
                if name == "reshape":
                    arg = [h, params["shape"]]
                elif name == "conv2d":
                    arg = [h, params["outSize"]]
                elif name == "max_pool":
                    arg = [h]
                elif name == "flatten":
                    arg = [h]
                elif name == "fc":
                    arg = [h, params["outSize"], params["act"]]
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

    def train(self, config, data_path, ws=None, model_info=None):

        ratio = float(config["data"].get("ratio", 0.1))
        self.ima.load_data(os.path.join(self.data_dir, data_path), ratio=ratio)

        with tf.Graph().as_default():
            print("start session")
            with tf.Session() as sess:
                self.build_nn()
                self.id = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
                self.out_dir = os.path.join(out_dir, self.id)

                if model_info:
                    print("save model info")
                    model_info["train_config"] = config
                    r = put_model_info(model_info, self.id)
                    print(r)

                global_step = tf.Variable(0, name="global_step", trainable=False)
                learning_rate = float(config["learning_rate"])
                optimizer = tf.train.AdamOptimizer(learning_rate)
                grads_and_vars = optimizer.compute_gradients(self.loss)
                train_op = optimizer.apply_gradients(grads_and_vars, global_step=global_step)


                grad_summaries = []
                for g, v in grads_and_vars:
                    if g is not None:
                        grad_hist_summary = tf.summary.histogram("{}/grad/hist".format(v.name), g)
                        sparsity_summary = tf.summary.scalar("{}/grad/sparsity".format(v.name), tf.nn.zero_fraction(g))
                        grad_summaries.append(grad_hist_summary)
                        grad_summaries.append(sparsity_summary)
                grad_summaries_merged = tf.summary.merge(grad_summaries)

                loss_summary = tf.summary.scalar("loss", self.loss)
                acc_summary = tf.summary.scalar("accuracy", self.accuracy)

                train_summary_op = tf.summary.merge([loss_summary, acc_summary, grad_summaries_merged])

                train_summary_dir = os.path.join(self.out_dir, "summaries", "train")
                train_summary_writer = tf.summary.FileWriter(train_summary_dir, sess.graph)

                test_summary_op = tf.summary.merge([loss_summary, acc_summary])
                test_summary_dir = os.path.join(self.out_dir, "summaries", "test")
                test_summary_writer = tf.summary.FileWriter(test_summary_dir, sess.graph)

                if save_checkpoint:
                    num_checkpoints = int(config.get("num_checkpoints", 5))
                    checkpoint_dir = os.path.abspath(os.path.join(self.out_dir, "checkpoints"))
                    checkpoint_prefix = os.path.join(checkpoint_dir, "model")
                    os.makedirs(checkpoint_dir, exist_ok=True)
                    saver = tf.train.Saver(tf.global_variables(), max_to_keep=num_checkpoints)


                sess.run(tf.global_variables_initializer())

                epoch = float(config["epoch"])
                batch_size = int(config["batch_size"])
                self.n_iter = int(epoch * self.ima.n_train)

                for _ in tqdm(range(self.n_iter)):

                    labels, images = self.ima.next_batch("train", batch_size)
                    _, step = sess.run([train_op, global_step], feed_dict={self.x: images, self.y: labels})

                    if ws:
                        res = {"action": "learning", "iter": int(step), "nIter": self.n_iter, "id": self.id}
                        ws.send(json.dumps(res))

                    if step % int(config["saver"]["evaluate_every"]["train"]) == 0:
                        self.evaluate(sess, global_step, "train", train_summary_writer, train_summary_op, images, labels, ws=ws)

                    if step % int(config["saver"]["evaluate_every"]["test"]) == 0 and step != 0:
                        labels, images = self.ima.next_batch("test", self.ima.n_test)
                        res = self.evaluate(sess, global_step, "test", test_summary_writer, test_summary_op, images, labels, ws=ws)

                        if save_checkpoint:
                            path = saver.save(sess, checkpoint_prefix, global_step=int(res["iter"]))
                            print("Saved model checkpoint to {}\n".format(path))

                if int(res["iter"]) != self.n_iter:
                    labels, images = self.ima.next_batch("test", self.ima.n_test)
                    res= self.evaluate(sess, global_step, "test", test_summary_writer, test_summary_op, images, labels, ws=ws)

                test_summary_writer.close()
                train_summary_writer.close()
        return res
