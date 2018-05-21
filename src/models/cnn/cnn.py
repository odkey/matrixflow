import tensorflow as tf
import sys
import json
from pathlib import Path

from ..recipe import Model
from ..recipemanager import Manager as RecipeManager
from ..imagemanager import Manager as ImageManager


class CNN(Model):
    def __init__(self):
        print("init CNN model")
        self.rma = RecipeManager()
        self.ima = ImageManager()
        self.recipe = self.rma.load_recipe()
        print(json.dumps(self.recipe, indent=2))

    def build_nn(self):
        dim = 28
        x_shape = [None, dim*dim]
        y_shape = [None, 10]
        self.x, self.y = self.input(x_shape, y_shape)
        h_1 = self.reshape(self.x, [-1, dim, dim, 1])
        h_2 = self.conv2d(h_1)
        h_3 = self.max_pool(h_2)
        h_4 = self.flatten(h_3)
        h_5 = self.fc(h_4)

        self.loss(h_5)
        self.acc(h_5)

    def train(self, data_path):
        self.ima.load_data(data_path)

        log_dir = "./log"
        if tf.gfile.Exists(log_dir):
            tf.gfile.DeleteRecursively(log_dir)
        tf.gfile.MakeDirs(log_dir)

        config = self.recipe["train"]

        with tf.Graph().as_default():
            with tf.Session() as sess:
                self.build_nn()
                summary_writer = tf.summary.FileWriter(log_dir, sess.graph)

                global_step = tf.Variable(0, name="global_step", trainable=False)
                optimizer = tf.train.AdamOptimizer(config["learning_rate"])
                grads_and_vars = optimizer.compute_gradients(self.loss)
                train_op = optimizer.apply_gradients(grads_and_vars, global_step=global_step)

                sess.run(tf.global_variables_initializer())
