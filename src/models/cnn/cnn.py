import tensorflow as tf
import sys
import json
from tqdm import tqdm

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
        #x_shape = [None, dim*dim]
        x_shape = [None, dim, dim]
        y_shape = [None, 10]
        self.x, self.y = self.input(x_shape, y_shape)
        h_1 = self.reshape(self.x, [-1, dim, dim, 1])
        h_2 = self.conv2d(h_1)
        h_3 = self.max_pool(h_2)
        h_4 = self.flatten(h_3)
        h_5 = self.fc(h_4, size=1024)
        h_6 = self.fc(h_5, size=10)

        self.loss(h_6)
        self.acc(h_6)

    def train(self, data_path):
        self.ima.load_data(data_path)

        log_dir = "./log"
        if tf.gfile.Exists(log_dir):
            tf.gfile.DeleteRecursively(log_dir)
        tf.gfile.MakeDirs(log_dir)

        config = self.recipe["train"]

        with tf.Graph().as_default():
            print("start session")
            with tf.Session() as sess:
                self.build_nn()
                summary_writer = tf.summary.FileWriter(log_dir, sess.graph)

                global_step = tf.Variable(0, name="global_step", trainable=False)
                optimizer = tf.train.AdamOptimizer(config["learning_rate"])
                grads_and_vars = optimizer.compute_gradients(self.loss)
                train_op = optimizer.apply_gradients(grads_and_vars, global_step=global_step)

                sess.run(tf.global_variables_initializer())
                epoch = config["epoch"]
                batch_size = config["batch_size"]
                for i in tqdm(range(int(epoch * self.ima.n_train))):
                    labels, images = self.ima.next_batch("train", batch_size)
                    sess.run(train_op, feed_dict={self.x: images, self.y: labels})
                    if i % config["saver"]["evaluate_every"] == 0:
                        train_loss, train_accuracy = sess.run([self.loss, self.accuracy], feed_dict={
                        self.x: images, self.y: labels})
                        print('step %d, training loss %g, training accuracy %g' % (i, train_loss, train_accuracy))
