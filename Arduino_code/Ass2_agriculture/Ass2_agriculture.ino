#include <PubSubClient.h>
#include <WiFi.h>
#include "DHT.h"

// Sensor definitions
#define DHTTYPE DHT11
#define DHTPIN 21  
#define SOIL_MOISTURE_PIN A2  
#define RAIN_SENSOR_PIN 47     
#define WATER_LEVEL_PIN A4   
#define RELAY_PIN 39    

const int redLEDPin   = 10;    
const int greenLEDPin = 9; 

// ------------------ Soil Moisture Settings -------------------
const int MinMoistureValue = 4095;
const int MaxMoistureValue = 1800;
const int MinMoisture      = 0;
const int MaxMoisture      = 100;
int Moisture               = 0;

// ------------------ Water Level Settings ---------------------
const int MinDepthValue = 0;
const int MaxDepthValue = 2800;
const int MinDepth      = 0;
const int MaxDepth      = 100;
int depth               = 0;

// WiFi and MQTT settings
const char* WIFI_SSID = "Zzzz";         // Your WiFi SSID
const char* WIFI_PASSWORD = "xgep8600"; // Your WiFi password
const char* MQTT_SERVER = "35.239.22.140"; 
const char* MQTT_TOPIC_SENSORS = "agriculture/sensors"; // MQTT topic for publishing sensor data
const char* MQTT_TOPIC_COMMANDS = "agriculture/commands"; // MQTT topic for receiving commands
const int MQTT_PORT = 1883; 

// Initialize DHT sensor
DHT dht(DHTPIN, DHTTYPE);

// Initialize WiFi and MQTT clients
WiFiClient espClient;
PubSubClient client(espClient);

// Relay state
bool relayState = false;  // OFF by default

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void setup() {
  Serial.begin(115200);  // Start serial communication
  dht.begin();           // Initialize DHT sensor
  pinMode(SOIL_MOISTURE_PIN, INPUT);  // Soil moisture sensor pin
  pinMode(RAIN_SENSOR_PIN, INPUT);    // Rain sensor pin
  pinMode(WATER_LEVEL_PIN, INPUT);    // Water level sensor pin
  pinMode(RELAY_PIN, OUTPUT);         // Relay control pin
  pinMode(redLEDPin, OUTPUT);
  pinMode(greenLEDPin, OUTPUT);

  digitalWrite(redLEDPin, HIGH);
  digitalWrite(greenLEDPin, LOW);
  digitalWrite(RELAY_PIN, LOW);       // Ensure relay is OFF at startup
  setup_wifi();          // Connect to WiFi network
  client.setServer(MQTT_SERVER, MQTT_PORT);  // Set up MQTT server
  client.setCallback(callback);  // Set MQTT message callback
}

void loop() {
  if (!client.connected()) {
    reconnect();  // Attempt to reconnect if not connected to MQTT server
  }
  client.loop();  // Maintain MQTT connection

  // Read sensor data
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  int soilMoistureRaw = analogRead(SOIL_MOISTURE_PIN);
  int rainSensorStatus = digitalRead(RAIN_SENSOR_PIN);
  int waterLevelRaw = analogRead(WATER_LEVEL_PIN);

  // Map raw values to percentages
  int soilMoisture = map(soilMoistureRaw, MinMoistureValue, MaxMoistureValue, MinMoisture, MaxMoisture);
  soilMoisture = constrain(soilMoisture, MinMoisture, MaxMoisture);

  int waterLevel = map(waterLevelRaw, MinDepthValue, MaxDepthValue, MinDepth, MaxDepth);
  waterLevel = constrain(waterLevel, MinDepth, MaxDepth);

  // Prepare JSON payload for MQTT publishing
  String payload = "{";
  payload += "\"temperature\":" + String(temperature, 2) + ",";
  payload += "\"humidity\":" + String(humidity, 2) + ",";
  payload += "\"soil_moisture\":" + String(soilMoisture) + ",";
  payload += "\"rain_status\":\"" + String(rainSensorStatus == HIGH ? "No Rain" : "Raining") + "\",";
  payload += "\"water_level\":" + String(waterLevel) + ",";
  payload += "\"relay_state\":\"" + String(relayState ? "ON" : "OFF") + "\"";
  payload += "}";

  // Publish JSON payload to MQTT topic
  if (client.publish(MQTT_TOPIC_SENSORS, payload.c_str())) {
    Serial.println("Data published successfully:");
    Serial.println(payload);
  } else {
    Serial.println("Failed to publish data to MQTT broker.");
  }

  delay(5000);  // Delay before reading again (5 seconds)
}

void callback(char* topic, byte* payload, unsigned int length) {
  payload[length] = '\0';  // Null-terminate the payload
  String message = String((char*)payload);
  Serial.print("Received message on topic ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(message);

  // Process commands for relay control
  if (String(topic) == MQTT_TOPIC_COMMANDS) {
    if (message == "ON") {
      digitalWrite(RELAY_PIN, HIGH);  // Turn relay ON
      digitalWrite(greenLEDPin, HIGH);
      relayState = true;
      Serial.println("Relay turned ON");
    } else if (message == "OFF") {
      digitalWrite(RELAY_PIN, LOW);  // Turn relay OFF
      digitalWrite(redLEDPin, HIGH);
      relayState = false;
      Serial.println("Relay turned OFF");
    } else {
      Serial.println("Unknown command received.");
    }
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.println("Attempting MQTT connection...");
    if (client.connect("ESP32Client")) {
      Serial.println("Connected to MQTT server");
      // Subscribe to the commands topic
      client.subscribe(MQTT_TOPIC_COMMANDS);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}