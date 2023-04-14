#!~/miniconda3/envs/tf2/bin/python
import json
import os
import platform

import numpy as np
import tensorflow as tf
from scipy.io import loadmat

from config import (batch_size, gaussian_sigma, gpu_dynamic_memory,
                    joint_names, num_joints)


# guassian generation
# 获取heatmap(通过高斯分布生成)
# @param: heatmap_size: heatmap的大小
def getGaussianMap(joint=(16, 16), heat_size=128, sigma=2):
    # by default, the function returns a gaussian map with range [0, 1] of typr float32
    heatmap = np.zeros((heat_size, heat_size), dtype=np.float32)
    tmp_size = sigma * 3
    # 上左
    ul = [int(joint[0] - tmp_size), int(joint[1] - tmp_size)]
    # 下右
    br = [int(joint[0] + tmp_size + 1), int(joint[1] + tmp_size + 1)]
    # 整个joint点的heatmap的大小
    size = 2 * tmp_size + 1
    x = np.arange(0, size, 1, np.float32)
    y = x[:, np.newaxis]
    x0 = y0 = size // 2
    g = np.exp(-((x - x0) ** 2 + (y - y0) ** 2) / (2 * (sigma ** 2)))
    g.shape
    # usable gaussian range
    # 计算heatmap的外框坐标
    g_x = max(0, -ul[0]), min(br[0], heat_size) - ul[0]
    g_y = max(0, -ul[1]), min(br[1], heat_size) - ul[1]
    # image range
    img_x = max(0, ul[0]), min(br[0], heat_size)
    img_y = max(0, ul[1]), min(br[1], heat_size)
    heatmap[img_y[0]:img_y[1], img_x[0]:img_x[1]
            ] = g[g_y[0]:g_y[1], g_x[0]:g_x[1]]
    """
    heatmap *= 255
    heatmap = heatmap.astype(np.uint8)
    cv2.imshow("debug", heatmap)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    """
    return heatmap


if gpu_dynamic_memory:
    # Limit GPU memory usage if necessary
    gpus = tf.config.experimental.list_physical_devices('GPU')
    if gpus:
        try:
            # Currently, memory growth needs to be the same across GPUs
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            logical_gpus = tf.config.experimental.list_logical_devices('GPU')
            print(len(gpus), "Physical GPUs,", len(
                logical_gpus), "Logical GPUs")
        except RuntimeError as e:
            # Memory growth must be set before GPUs have been initialized
            print(e)


# 获取数据集的大小
imageFiles = []
a = 1200
for file in os.listdir("./dataset/pullup"):
    if file.endswith(".jpg") and a > 0:
        a = a-1
        imageFiles.append(file)

imageNumber = len(imageFiles)


# read images
data = np.zeros([imageNumber, 256, 256, 3])
heatmap_set = np.zeros((imageNumber, 128, 128, num_joints), dtype=np.float32)
label = np.zeros((imageNumber, num_joints, 2))

print("Reading dataset...")
for i in range(imageNumber):
    FileName = "./dataset/pullup/%s" % (imageFiles[i])
    img = tf.io.read_file(FileName)
    img = tf.image.decode_image(img)
    img_shape = img.shape
    # 将照片上的坐标映射到256*256的尺寸上
    joints = json.load(open(FileName+".json", 'r', encoding="utf-8"))
    for j in range(num_joints):
        label[i, j, 0] = joints[joint_names[j]]['x'] * 256
        label[i, j, 1] = joints[joint_names[j]]['y'] * 256

    # 将照片缩放到256*256
    data[i] = tf.image.resize(img, [256, 256])
    # generate heatmap set
    for j in range(num_joints):
        _joint = (label[i, j, 0:2] // 2).astype(np.uint16)
        # print(_joint)
        heatmap_set[i, :, :, j] = getGaussianMap(
            joint=_joint, heat_size=128, sigma=gaussian_sigma)
    # print status
    if not i % (imageNumber//80):
        print(">", end='')

train_number = int(imageNumber*0.8)

# dataset
print("\nGenerating training and testing data batches...")
train_dataset = tf.data.Dataset.from_tensor_slices(
    (data[0:train_number], heatmap_set[0:train_number]))
test_dataset = tf.data.Dataset.from_tensor_slices(
    (data[train_number:-1], heatmap_set[train_number:-1]))

SHUFFLE_BUFFER_SIZE = 1000
train_dataset = train_dataset.shuffle(SHUFFLE_BUFFER_SIZE).batch(batch_size)
test_dataset = test_dataset.batch(batch_size)

# Finetune
finetune_train = tf.data.Dataset.from_tensor_slices(
    (data[0:train_number], label[0:train_number]))
finetune_validation = tf.data.Dataset.from_tensor_slices(
    (data[train_number:-1], label[train_number:-1]))

finetune_train = finetune_train.shuffle(SHUFFLE_BUFFER_SIZE).batch(batch_size)
finetune_validation = finetune_validation.batch(batch_size)

print("Done.")
