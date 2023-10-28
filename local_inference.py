import os
import numpy as np
import imageio.v2 as imageio
import cv2
import math
from glob import glob
from keras.models import load_model
from tqdm import tqdm


model = load_model('model/model.h5')

# Read and preprocess the image
img_A_path = "lim.jpeg"
img_A = imageio.imread(img_A_path) / 255.
H, W, C = img_A.shape
img_A = img_A[:, :, :3]
img_A = cv2.resize(img_A, (256, 256), interpolation=cv2.INTER_LANCZOS4)
img_A = img_A[np.newaxis, :]

# Make predictions
out_pred = model.predict(img_A)

# Convert the prediction to the 0-255 range and uint8 format
out_pred = (out_pred * 255.).astype(np.uint8)

# Convert the color channel order from RGB to BGR
out_pred_bgr = cv2.cvtColor(out_pred[0], cv2.COLOR_RGB2BGR)

out_pred_bgr = cv2.resize(out_pred_bgr, (W, H), interpolation=cv2.INTER_LANCZOS4)

# Save the image using OpenCV with the correct BGR channel order
cv2.imwrite('output.png', out_pred_bgr)
