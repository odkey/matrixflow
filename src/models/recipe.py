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

    def input_data(self, x_shape, x_type=tf.float32):
        with tf.name_scope("input-data"):
            x = tf.placeholder(x_type, shape=x_shape)
        return x

    def input_labels(self, y_shape, y_type=tf.float32):
        with tf.name_scope("input-labels"):
            y = tf.placeholder(y_type, shape=y_shape)
        return y


    def reshape(self, input, shape):
        with tf.name_scope("reshape"):
            x = tf.reshape(input, shape)
        return x

    def conv2d(self, input, out_size, act="relu"):
        out_size = int(out_size)
        shape = input.get_shape().as_list()
        in_channel = shape[-1]
        with tf.name_scope("conv_1"):
            filt = tf.Variable(tf.truncated_normal([5, 5, in_channel, out_size], stddev=0.01))
            conv = tf.nn.conv2d(input, filt, strides=[1, 1, 1, 1], padding="SAME")
            b = tf.Variable(tf.constant(0.1, shape=[out_size]))
            h = tf.nn.bias_add(conv, b)
        return self.activation(h, act)

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

    def activation(self, h, type):
        if type == "relu":
            output = tf.nn.relu(h)
        elif type == "ident":
            output = h
        else:
            pass
        return output

    def fc(self, input, size=10, act="relu"):
        with tf.name_scope("fc"):
            shape = int(input.shape[1])
            W = self.weight_variable([shape, size])
            b = self.bias_variable(shape=[size])
            h = tf.nn.bias_add(tf.matmul(input, W), b)
        return self.activation(h, act)

    def loss(self, output):
        with tf.name_scope("loss"):
            self.loss = tf.reduce_mean(
                tf.nn.softmax_cross_entropy_with_logits_v2(labels=self.y, logits=output))

    def acc(self, output):
        with tf.name_scope("accuracy"):
            correct = tf.equal(tf.argmax(output, 1), tf.argmax(self.y, 1))
            self.accuracy = tf.reduce_mean(tf.cast(correct, tf.float32))
