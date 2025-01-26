from flask import Flask, request, jsonify
from flask_cors import CORS
import pymongo
import threading
import paho.mqtt.client as mqtt
from datetime import datetime, timezone
import json

# Initialize Flask app
app = Flask(__name__)
CORS(app)  

# MongoDB Configuration
mongo_client = pymongo.MongoClient("mongodb://localhost:27017/")
db = mongo_client["smart_agriculture"]
sensors_collection = db["sensors"]
commands_collection = db["commands"]

# MQTT Configuration
mqtt_broker_address = "35.239.22.140"  
mqtt_topic_sensors = "agriculture/sensors"  # Topic for sensor data
mqtt_topic_commands = "agriculture/commands"  # Topic for actuator commands

# Flask API Routes

# Route to fetch sensor data
@app.route('/agriculture/sensors', methods=['GET'])
def get_sensors():
    try:
        # Fetch the latest sensor data
        latest_sensor_data = sensors_collection.find().sort("timestamp", -1).limit(1)
        data = list(latest_sensor_data)[0] if latest_sensor_data.count() > 0 else {}
        data.pop('_id', None)  # Remove MongoDB object ID for cleaner JSON response
        return jsonify(data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route to control relay (water pump)
@app.route('/agriculture/relay', methods=['POST'])
def control_relay():
    try:
        # Get the JSON payload from the request
        payload = request.json
        device = payload.get("device")
        command = payload.get("command")

        if not device or not command:
            return jsonify({"error": "Invalid payload"}), 400

        # Add the command to the MongoDB commands collection
        command_data = {
            "device": device,
            "command": command,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
        commands_collection.insert_one(command_data)

        # Publish the command to the MQTT broker
        mqtt_client.publish(mqtt_topic_commands, json.dumps(command_data))
        return jsonify({"message": f"Command '{command}' sent to '{device}'"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# MQTT Callbacks

# Callback for MQTT connection
def on_connect(client, userdata, flags, reason_code):
    if reason_code == 0:
        print("Successfully connected to MQTT broker")
        client.subscribe(mqtt_topic_sensors)  # Subscribe to sensor data topic
        print(f"Subscribed to topic: {mqtt_topic_sensors}")
    else:
        print(f"Failed to connect, return code {reason_code}")

# Callback for processing received MQTT messages
def on_message(client, userdata, message):
    payload = message.payload.decode("utf-8")
    print(f"Received message on topic '{message.topic}': {payload}")

    # Get current timestamp in ISO 8601 format
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")

    if message.topic == mqtt_topic_sensors:
        try:
            # Parse sensor data from JSON payload
            sensor_data = json.loads(payload)
            sensor_data["timestamp"] = timestamp  # Add a timestamp
            sensors_collection.insert_one(sensor_data)  # Insert into MongoDB
            print("Sensor data ingested into MongoDB")
        except Exception as e:
            print(f"Error processing sensor data: {e}")

# MQTT Client Setup
mqtt_client = mqtt.Client()

# Attach the callbacks
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

# Connect to the MQTT broker
def start_mqtt_client():
    print(f"Connecting to MQTT broker at {mqtt_broker_address}...")
    mqtt_client.connect(mqtt_broker_address, 1883, 60)
    print("Starting MQTT loop...")
    mqtt_client.loop_forever()

# Start Flask App
def start_flask_app():
    app.run(host="0.0.0.0", port=5000)

# Run MQTT and Flask concurrently using threads
if __name__ == "__main__":
    mqtt_thread = threading.Thread(target=start_mqtt_client)
    mqtt_thread.daemon = True
    mqtt_thread.start()

    # Start Flask app
    start_flask_app()