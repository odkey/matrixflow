import tensorflow as tf
import sys

from ..recipe import Model
from ..recipemanager import Manager



class CNN(Model):
    def __init__(self):
        print("init CNN model")
        rma = Manager()
        recipe = rma.load_recipe()
        print(recipe)


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





    def train(self):
        log_dir = "./log"
        if tf.gfile.Exists(log_dir):
            tf.gfile.DeleteRecursively(log_dir)
        tf.gfile.MakeDirs(log_dir)

        with tf.Graph().as_default():
            with tf.Session() as sess:
                self.build_nn()
                summary_writer = tf.summary.FileWriter(log_dir , sess.graph)
                tf.summary.scalar('loss', self.loss)

                sess.run(tf.global_variables_initializer())
