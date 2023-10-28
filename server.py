import base64
import numpy as np
from keras.models import load_model
from flask import Flask, request, jsonify

app = Flask(__name__)

model = None
def get_model():
    global model
    if model is None:
        model = load_model('model.h5')
    return model

@app.route('/upload', methods=['POST'])

def hello_world():
    model = get_model()

    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})
    file = request.files['file'].read()

    if file:
        #convert string data to numpy array
        file_bytes = np.frombuffer(file, np.uint8)
        # convert numpy array to image
        img_A = cv2.imdecode(file_bytes, cv2.IMREAD_UNCHANGED) / 255.0
        img_A = img_A[:, :, :3]
        H, W, C = img_A.shape
        img_A = cv2.resize(img_A, (256, 256), interpolation=cv2.INTER_LANCZOS4)
        img_A = img_A[np.newaxis, :]

        # Make predictions
        out_pred = model.predict(img_A)

        # Convert the prediction to the 0-255 range and uint8 format
        out_pred = (out_pred * 255).astype(np.uint8)

        out_pred_bgr = cv2.resize(out_pred[0], (W, H), interpolation=cv2.INTER_LANCZOS4)

        _, encoded_image = cv2.imencode('.png', out_pred_bgr)
        encoded_image = base64.b64encode(encoded_image.tobytes()).decode('ascii')

        # Return the base64-encoded image as a JSON response
        return jsonify({'image': encoded_image})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
