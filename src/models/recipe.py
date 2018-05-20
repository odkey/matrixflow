import tensorflow as tf


class Model:
    def __init__(self):
        print("Model class __init__")

    def weight_variable(self, shape):
        w = tf.truncated_normal(shape, stddev=0.01)
        return tf.Variable(w)


    def bias_variable(self, shape):
        b = tf.constant(0.1, shape=shape)
        return tf.Variable(b)

    def input(self, x_shape, y_shape, x_type=tf.float32, y_type=tf.float32):
        with tf.name_scope("input"):
            x = tf.placeholder(x_type, shape=x_shape)
            y = tf.placeholder(y_type, shape=y_shape)
        return x, y


    def reshape(self, input, shape):
        with tf.name_scope("reshape"):
            x = tf.reshape(input, shape)
        return x

    def conv2d(self, input):
        with tf.name_scope("conv_1"):
            filt = tf.Variable(tf.truncated_normal([5, 5, 1, 32], stddev=0.01))
            conv = tf.nn.conv2d(input, filt, strides=[1,1,1,1], padding="SAME")
            b = tf.Variable(tf.constant(0.1, shape=[32]))
            h = tf.nn.bias_add(conv, b)
            output = tf.nn.relu(h)
        return output

    def max_pool(self, input):
        with tf.name_scope("pool_1"):
            output = tf.nn.max_pool(input, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding="SAME")
        return output

    def flatten(self, input):
        with tf.name_scope("flatten"):
            shape = input.shape
            dim = int(shape[1] * shape[2] * shape[3])
            output = tf.reshape(input, [-1, dim])
        return output

    def fc(self, input):
        with tf.name_scope("fc"):
            shape = int(input.shape[1])
            W = self.weight_variable([shape, 1024])
            b = self.bias_variable(shape=[1024])
            h = tf.nn.bias_add(tf.matmul(input, W), b)
            output = tf.nn.relu(h)
        return output


    def loss(self, output):
        with tf.name_scope("loss"):
            self.loss = tf.reduce_mean(
                tf.nn.softmax_cross_entropy_with_logits(labels=self.y, logits=output))

    def acc(self, output):
        with tf.name_scope("accuracy"):
            correct = tf.equal(tf.argmax(output, 1), tf.argmax(self.y, 1))
            self.accuracy = tf.reduce_mean(tf.cast(correct, tf.float32))
