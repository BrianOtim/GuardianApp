#include <Wire.h>
#include <SPI.h>
#include "SD.h"
#include "FS.h"
#include <WiFi.h>
#include <HTTPClient.h>

// Replace with your network credentials
const char* ssid = "test";
const char* password = "test12345";

// Replace with your endpoint URL
const char* serverUrl = "http://192.168.43.175:5000/upload";

const int buttonPin = 2;
const int soundPin = 35; // Analog pin connected to sound sensor
const int threshold = 500; // Adjust as per your requirement
const int chipSelect = 5; // Pin connected to SD card module

int buttonState = 0; 

File audioFile;

int MIN_DATA_VALUE = 0;
int MAX_DATA_VALUE = 4095;

// WAV file header information
char chunkID[4] = {'R', 'I', 'F', 'F'};
uint32_t chunkSize = 36;
char format[4] = {'W', 'A', 'V', 'E'};
char subChunk1ID[4] = {'f', 'm', 't', ' '};
uint32_t subChunk1Size = 16;
uint16_t audioFormat = 1;
uint16_t numChannels = 1;
uint32_t sampleRate = 44100;
uint32_t byteRate = 44100 * 2;
uint16_t blockAlign = 2;
uint16_t bitsPerSample = 16;
char subChunk2ID[4] = {'d', 'a', 't', 'a'};
uint32_t subChunk2Size = 0;



void setup() {
  Serial.begin(9600);
  delay(1000);
  
  // Initialize SD card
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    return;
  }
  Serial.println("Card initialized.");

  // Initialize sound sensor
  pinMode(soundPin, INPUT);

   pinMode(buttonPin, INPUT);


  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);
  // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  if (buttonState == HIGH) {
    
    Serial.println("ON PRESSED");
    int soundLevel = analogRead(soundPin);
    Serial.print("Sound level: ");
    Serial.println(soundLevel);

    if (soundLevel > threshold) 
    {
          recordAudio();
    }
    
  }
  delay(100);
}

void recordAudio() {
  String fileName = "/recording_" + String(random(1000)) + ".wav"; // Generate filename with random integer
  audioFile = SD.open(fileName, FILE_WRITE);

  if (audioFile) {
    writeWavHeader(audioFile);
    unsigned long startTime = millis();
    unsigned long duration = 5000; // 5 seconds
    while (millis() - startTime < duration) {
      int soundData = analogRead(soundPin);
      writeDataToWavFile(audioFile, soundData);
    }
    finalizeWavFile(audioFile); // Finalize the WAV file with correct sizes
    delay(200);
    audioFile.close();
    Serial.println("Recording saved as: " + fileName);

    // Upload the recorded file
    uploadFile(fileName);
  } else {
    Serial.println("Error opening file for writing");
  }
}

void writeWavHeader(File wavFile) {
  subChunk2Size = 0; // Reset subChunk2Size before recording
  chunkSize = 36; // Reset chunkSize before recording

  wavFile.seek(0);
  wavFile.write((const uint8_t*)chunkID, 4);
  wavFile.write((const uint8_t*)&chunkSize, 4);
  wavFile.write((const uint8_t*)format, 4);
  wavFile.write((const uint8_t*)subChunk1ID, 4);
  wavFile.write((const uint8_t*)&subChunk1Size, 4);
  wavFile.write((const uint8_t*)&audioFormat, 2);
  wavFile.write((const uint8_t*)&numChannels, 2);
  wavFile.write((const uint8_t*)&sampleRate, 4);
  wavFile.write((const uint8_t*)&byteRate, 4);
  wavFile.write((const uint8_t*)&blockAlign, 2);
  wavFile.write((const uint8_t*)&bitsPerSample, 2);
  wavFile.write((const uint8_t*)subChunk2ID, 4);
  wavFile.write((const uint8_t*)&subChunk2Size, 4);
}

void writeDataToWavFile(File wavFile, int data) {
  int16_t sampleValue = map(data, MIN_DATA_VALUE, MAX_DATA_VALUE, -32767, 32767);

  // Write sample data
  wavFile.write((const uint8_t*)&sampleValue, 2);

  // Update subChunk2Size and chunkSize
  subChunk2Size += numChannels * bitsPerSample / 8;
  chunkSize = 36 + subChunk2Size;
}

void finalizeWavFile(File wavFile) {
  // Update the chunkSize and subChunk2Size in the file header
  wavFile.seek(4);
  wavFile.write((const uint8_t*)&chunkSize, 4);

  wavFile.seek(40);
}

void uploadFile(String fileName) {
  if (WiFi.status() == WL_CONNECTED) {
    File file = SD.open(fileName, FILE_READ);
    if (!file) {
      Serial.println("Failed to open file for reading");
      return;
    }

    WiFiClient client;
    if (!client.connect("192.168.137.1", 5000)) {
      Serial.println("Connection to server failed");
      return;
    }

    // Remove leading slash from the filename
    String fileNameNoSlash = fileName;
    if (fileNameNoSlash.startsWith("/")) {
      fileNameNoSlash = fileNameNoSlash.substring(1);
    }

    
    String boundary = "--------------------------" + String(millis(), HEX);
    String header = "--" + boundary + "\r\n";
    header += "Content-Disposition: form-data; name=\"victim_id\"\r\n\r\n4\r\n";
    header += "--" + boundary + "\r\n";
    header += "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileNameNoSlash + "\"\r\n";
    header += "Content-Type: audio/wav\r\n\r\n";
    String footer = "\r\n--" + boundary + "--\r\n";

    int contentLength = header.length() + file.size() + footer.length();

    // Construct the HTTP POST request
    client.println("POST /upload HTTP/1.1");
    client.println("Host: 192.168.137.1");
    client.println("Content-Type: multipart/form-data; boundary=" + boundary);
    client.println("Content-Length: " + String(contentLength));
    client.println();
    client.print(header);

    uint8_t buffer[512];
    while (file.available()) {
      int len = file.read(buffer, sizeof(buffer));
      if (len > 0) {
        client.write(buffer, len);
      } else {
        Serial.println("Error reading from file");
        break;
      }
    }

    client.print(footer);

    // Wait for server response
    unsigned long timeout = millis();
    while (client.connected() && millis() - timeout < 10000) {
      if (client.available()) {
        String line = client.readStringUntil('\n');
        if (line == "\r") {
          break;
        }
      }
    }

    // Read the response
    String response = client.readString();
    Serial.println("Server response:");
    Serial.println(response);

    file.close();
    client.stop();
  } else {
    Serial.println("WiFi not connected");
  }
}
