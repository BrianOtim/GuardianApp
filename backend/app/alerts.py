from flask import Blueprint, request, jsonify, current_app

from .database import get_db
from flask_mail import Message
from . import mail

alerts_bp = Blueprint('alerts', __name__)


# CRUD routes for alerts
# Example:
@alerts_bp.route('/alerts', methods=['POST'])
def add_alert():
    data = request.get_json()

    # Check if victimId and message fields exist in the request
    required_fields = ['victimId', 'message']
    if not all(key in data for key in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400

    victim_id = data.get('victimId')
    message = data.get('message')
    
    address = get_location(str(victim_id)).split("/")
    lat = address[0]
    long = address[1]
    place = address[2] 

    # Check if victimId is a valid integer
    if not isinstance(victim_id, int):
        return jsonify({'error': 'Invalid victimId'}), 400

    # Check if the victim exists in the database
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE id = ?", (victim_id,))
    victim = cur.fetchone()
    if not victim:
        return jsonify({'error': 'Victim not found'}), 404

    # Insert the alert into the database
    cur.execute("INSERT INTO alerts (victimId, message, latitude, logitude, place) VALUES (?, ?, ?, ?, ?)", (victim_id, message, lat, long, place))
    db.commit()
    cur.close()

    return jsonify({'message': 'Alert created successfully'}), 200

@alerts_bp.route('/alerts/<int:user_id>', methods=['GET'])
def get_alerts(user_id):
    # Check if the user exists in the database
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cur.fetchone()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Query the database for the alerts of the user
    cur.execute("SELECT * FROM alerts WHERE victimId = ?", (user_id,))
    alerts = cur.fetchall()

    # Convert alert data to a list of dictionaries
    alert_list = [{
        'id': alert[0],
        'victimId': alert[1], 
        'message': alert[2],
        'latitude': alert[3],
        'logitude': alert[4],
        'place': alert[5]
        } for alert in alerts]

    # Create a dictionary representing the user object
    user_obj = {
        'id': user[0],
        'username': user[1],
        'email': user[2],
        'contact': user[3],
        'role': user[5]
    }

    return jsonify({'user': user_obj, 'alerts': alert_list}), 200

@alerts_bp.route('/alerts/<int:alert_id>', methods=['DELETE'])
def delete_alert(alert_id):
    # Check if the alert exists in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM alerts WHERE id = ?", (alert_id,))
    alert = cur.fetchone()
    if not alert:
        return jsonify({'error': 'Alert not found'}), 404

    # Delete the alert from the database
    cur.execute("DELETE FROM alerts WHERE id = ?", (alert_id,))
    db.commit()
    cur.close()

    return jsonify({'message': 'Alert deleted successfully'}), 200

@alerts_bp.route('/alerts/user/<int:user_id>', methods=['DELETE'])
def delete_user_alerts(user_id):
    # Check if the user exists in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cur.fetchone()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Delete all alerts associated with the user
    cur.execute("DELETE FROM alerts WHERE victimId = ?", (user_id,))
    db.commit()
    cur.close()

    return jsonify({'message': 'All alerts for the user deleted successfully'}), 200



import base64
import os
from datetime import datetime

import tensorflow as tf
import numpy as np
import librosa
import soundfile as sf


@alerts_bp.route('/decode-audio', methods=['POST'])
def decode_and_store_audio():
    # Get base64 encoded audio data from the request
    data = request.get_json()
    audio_base64 = data.get('audio_base64')
    victim_id = data.get('victimId')
    

    if not audio_base64:
        return jsonify({'error': 'Base64 audio data is required'}), 400
    
    if not isinstance(victim_id, int):
        return jsonify({'error': 'Invalid victimId'}), 400
    
    
    # Check if the victim exists in the database
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE id = ?", (victim_id,))
    victim = cur.fetchone()
    if not victim:
        return jsonify({'error': 'Victim not found'}), 404

    try:
        # Decode base64 audio data
        audio_data = base64.b64decode(audio_base64)
        # Create the "alerts" directory if it doesn't exist
        alerts_dir = os.path.join(current_app.root_path, 'alerts')
        os.makedirs(alerts_dir, exist_ok=True)
        # Generate timestamp
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        # Create the filename with timestamp
        original_audio_file_name = f'decoded_audio_{timestamp}.wav'
        audio_file_path = os.path.join(alerts_dir, original_audio_file_name)
        # Write the decoded audio data to the file
        with open(audio_file_path, 'wb') as audio_file:
            audio_file.write(audio_data)
            
       
        # load our model
        model_dir = os.path.join(current_app.root_path, 'model')
        os.makedirs(model_dir, exist_ok=True)
        # Path to the model
        model_path = os.path.join(model_dir, 'my_model.h5')
        # Check if the model file exists
        if not os.path.exists(model_path):
            return jsonify({'error': "Model file does not exist"}), 500

        # Load the model
        loaded_model = tf.keras.models.load_model(model_path)
        
        waveform, sample_rate = librosa.load(audio_file_path, sr=16000, mono=True)
        
        # Apply a high-pass filter to remove low-frequency noise
        high_pass_filter = librosa.effects.preemphasis(waveform)
        clean_audio_dir = os.path.join(current_app.root_path, 'clean_audio')
        os.makedirs(clean_audio_dir, exist_ok=True)
        # Save the denoised audio
        output_path = os.path.join(clean_audio_dir, original_audio_file_name)
        sf.write(output_path, high_pass_filter, sample_rate)
        if not os.path.exists(output_path):
            return jsonify({'error': "cleaned file does not exist"}), 500
        
        # Continue with the usual processing
        waveform = tf.convert_to_tensor(high_pass_filter, dtype=tf.float32)
        x = get_spectrogram(waveform)
        x = x[tf.newaxis, ...]

        # Make prediction
        prediction = loaded_model(x)
        x_labels = ['help', 'leave me', 'please']
        predicted_label = tf.argmax(prediction[0]).numpy()
        predicted_label_name = x_labels[predicted_label]

        # Print the predicted label
        print("Predicted label is:", predicted_label_name)
        # Check if the victim exists in the database
        db = get_db()
        cur = db.cursor()
        cur.execute("SELECT * FROM users WHERE id = ?", (victim_id,))
        victim = cur.fetchone()
        if not victim:
            return jsonify({'error': 'Victim not found'}), 404
        
        
        message = f"'{predicted_label_name}' detected on safe device of {victim[2]} at " + str(datetime.now().strftime('%Y-%m-%d')) + " at " + str(datetime.now().strftime('%H:%M:%S'))
        address = get_location(str(victim_id)).split("/")
        lat = address[0]
        long = address[1]
        place = address[2] 

        # Insert the alert into the database
        cur.execute("INSERT INTO alerts (victimId, message, latitude, logitude, place) VALUES (?, ?, ?, ?, ?)", (victim_id, message, lat, long, place))        
        db.commit()
        #cur.close()
        
        # Retrieve victim's email
        victim_email = victim[2]
        # Retrieve guardian emails
        cur.execute("SELECT u.email FROM guardians g JOIN users u ON g.guardianId = u.id WHERE g.userId = ?", (victim_id,))
        guardian_emails = [row[0] for row in cur.fetchall()]

        # Send emails
        recipients = [victim_email] + guardian_emails
        msg = Message('Alert Notification', recipients=recipients)
        msg.body = f"Alert message: {message}"
        mail.send(msg)
        cur.close()
        
        return jsonify({'message': 'Audio file decoded and stored successfully', 
                        'file_path': audio_file_path, 
                        'prediction': predicted_label_name}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
def get_spectrogram(waveform):
  # Convert the waveform to a spectrogram via a STFT.
  spectrogram = tf.signal.stft(
      waveform, frame_length=255, frame_step=128)
  # Obtain the magnitude of the STFT.
  spectrogram = tf.abs(spectrogram)
  spectrogram = spectrogram[..., tf.newaxis]
  return spectrogram


@alerts_bp.route('/send-email',methods=['POST'])
def send_email():
        recipient = '109walt@gmail.com'
        subject = 'Test Email'
        body = 'This is a test email sent from Flask.'

        # Create a message object
        msg = Message(subject, recipients=[recipient], body=body)

        try:
            # Send the message
            mail.send(msg)
            return 'Email sent successfully!'
        except Exception as e:
            return str(e)
        
@alerts_bp.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'status': 'fail', 'message': 'No file part in the request'}), 400

    file = request.files['file']
    victim_id = request.form.get('victim_id')

    if file.filename == '':
        return jsonify({'status': 'fail', 'message': 'No selected file'}), 400

    if not victim_id:
        return jsonify({'status': 'fail', 'message': 'No victim ID provided'}), 400
    
    # Check if the victim exists in the database
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE id = ?", (victim_id,))
    victim = cur.fetchone()
    if not victim:
        return jsonify({'error': 'Victim not found'}), 404

    try:
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], file.filename)
        file.save(file_path)
        file_path = slow_down_audio(file_path, 2.2)
    except Exception as e:
        cur.close()
        return jsonify({'status': 'fail', 'message': str(e)}), 500
    
    
    try:
        # load our model
        model_dir = os.path.join(current_app.root_path, 'model')
        os.makedirs(model_dir, exist_ok=True)
        # Path to the model
        model_path = os.path.join(model_dir, 'my_model.h5')
        # Check if the model file exists
        if not os.path.exists(model_path):
            return jsonify({'error': "Model file does not exist"}), 500

        # Load the model
        loaded_model = tf.keras.models.load_model(model_path)
        
        waveform, sample_rate = librosa.load(file_path, sr=16000, mono=True)
        
        waveform = tf.convert_to_tensor(waveform, dtype=tf.float32)

        # Ensure get_spectrogram is defined in your code
        x = get_spectrogram(waveform)
        x = x[tf.newaxis, ...]
        # Make prediction
        prediction = loaded_model(x)
        # Get the predicted label
        x_labels = ['help', 'leave me', 'please']
        predicted_label = tf.argmax(prediction[0]).numpy()
        predicted_label_name = x_labels[predicted_label]
        # Print the predicted label
        print("Predicted label is:", predicted_label_name)
        # Check if the victim exists in the database
        
        message = f"'{predicted_label_name}' detected on safe device of {victim[2]} at " + str(datetime.now().strftime('%Y-%m-%d')) + " at " + str(datetime.now().strftime('%H:%M:%S'))

        address = get_location(str(victim_id)).split("/")
        lat = address[0]
        long = address[1]
        place = address[2] 

        parts = message.split(" at ")
        audio_name = parts[1] + " at "+ parts[2]
        record(audio_name)
        # Insert the alert into the database
        cur.execute("INSERT INTO alerts (victimId, message, latitude, logitude, place) VALUES (?, ?, ?, ?, ?)", (victim_id, message, lat, long, place))
        db.commit()
        #cur.close()
        
        # Retrieve victim's email
        victim_email = victim[2]
        # Retrieve guardian emails
        cur.execute("SELECT u.email FROM guardians g JOIN users u ON g.guardianId = u.id WHERE g.userId = ?", (victim_id,))
        guardian_emails = [row[0] for row in cur.fetchall()]

        # Send emails
        recipients = [victim_email] + guardian_emails
        msg = Message('Alert Notification', recipients=recipients)
        msg.body = f"Alert message: {message}"
        mail.send(msg)
        cur.close()
        
        return jsonify({'message': 'Audio file stored successfully', 
                        'file_path': file_path,
                        'victim': victim[2],
                        'prediction': predicted_label_name}), 200
        
    except Exception as e:
            return jsonify({'status': 'fail', 'message': str(e)}), 500
    
    
    
from pydub import AudioSegment
import os

def slow_down_audio(file_path, slowdown_factor):
    # Load the audio file
    audio = AudioSegment.from_file(file_path)
    
    # Calculate the new playback speed
    new_frame_rate = int(audio.frame_rate / slowdown_factor)
    
    # Apply the new frame rate to slow down the audio
    slowed_audio = audio._spawn(audio.raw_data, overrides={'frame_rate': new_frame_rate})
    
    # Maintain the original sample width and channels
    slowed_audio = slowed_audio.set_frame_rate(audio.frame_rate)
    
    # Construct the new file name
    base, ext = os.path.splitext(file_path)
    new_file_path = f"{base}_slowed_{slowdown_factor}x{ext}"
    
    # Export the slowed down audio to the new file
    slowed_audio.export(new_file_path, format="wav")
    print(f"Saved slowed down audio to {new_file_path}")
    return new_file_path


import socket
def get_location(id):
    phone_ip = "192.168.43.1"
    phone_port = 6000
    response = "0.0000000/32.0000000/9GR3+MRR, , Kampala,"
    try:
        phone = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        phone.connect((phone_ip, phone_port))
        print(f"[*] Connnecting to device> {phone_ip} : {phone_port}")
        phone.send("L".encode("UTF-8"))
        response = phone.recv(1024).decode("UTF-8")
        print(f"[*] Device says> {response}")
    except:
        pass
    phone.close()
    notify(id)
    return response

def notify(id):
    ip =  "192.168.43.21"
    port = 6000
    try:
        phone = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        phone.connect((ip, port))
        phone.send("T".encode("UTF-8"))
    except:
        pass
    phone.close()

def record(message):
    phone_ip = "192.168.43.1"
    phone_port = 6000
    try:
        phone = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        phone.connect((phone_ip, phone_port))
        phone.send(message.encode("UTF-8"))
        print(f"[*] File name to phone> {message}")
    except:
        pass
    phone.close()