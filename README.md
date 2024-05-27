# GuardianApp

GuardianApp is a comprehensive solution designed to offer immediate reporting and assistance for incidents of domestic violence. The system integrates a wearable device and a mobile application to ensure rapid response and support.

## Table of Contents
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Hardware Components](#hardware-components)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setting Up the Mobile Application](#setting-up-the-mobile-application)
  - [Setting Up the Backend](#setting-up-the-backend)
  - [Setting Up the Wearable Device](#setting-up-the-wearable-device)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- Emergency Alerts: Users can trigger alerts to guardians or emergency contacts using the wearable device.
- Trigger Methods: The wearable can be activated using an access button or by detecting specific trigger sounds.
- Machine Learning: Uses TensorFlow to detect trigger words such as "help", "please", and "leave me".
- Data Logging: The wearable records sound using a microphone module and stores it on a micro SD card.

## Technology Stack

### Mobile Application/ front end
- Framework: Flutter
- Platforms: Android, iOS

### Backend
- Framework: Flask (Python)
- Machine Learning: TensorFlow

### Hardware Components
- Microcontroller: ESP32
- Modules**:
  - Microphone Module
  - Micro SD Card Module
  - Arduino Breadboard

## Hardware Components

### Wearable Device
- ESP32 Controller: Manages the overall operation and communication.
- Microphone Module: Captures audio to detect trigger sounds.
- Micro SD Card Module: Records and stores audio data.
- Arduino Breadboard: Used for prototyping and connecting the components.
- Access Button: Physical button to trigger alerts.

## Installation

### Prerequisites
- **Flutter**: Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install).
- Python: Ensure Python 3.10 is installed. You can download it from the [official website](https://www.python.org/downloads/).
- Arduino IDE: Download and install the [Arduino IDE](https://www.arduino.cc/en/software).
- Android studio sdk

### Setting Up the Mobile Application

1. Clone the repository:
   ```sh
   git clone https://github.com/BrianOtim/GuardianApp.git
   cd GuardianApp/mobile_app

2. Install flutter: flutter pub get

3. Start application: flutter run

## Setting Up the Backend
4. cd ../backend
5. Create a virtual environment and activate it: python -m venv venv
source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
6. Install dependencies: pip install -r requirements.txt
7. Run the Flask application: flask run

## Setting Up the Wearable Device
Open the Arduino IDE.
Install the necessary libraries (ESP32, SD, and microphone libraries).
Connect the ESP32 to your computer and upload the code from the hardware directory in the repository.
Assemble the hardware components according to the provided schematic in the hardware/schematic directory.

## Usage
Trigger Alert: Press the access button or use one of the trigger words (help, please, leave me) near the wearable device.
Receive Alert: The mobile application will send notifications to the configured guardians or emergency contacts.
Data Logging: Audio is recorded and stored on the micro SD card in the wearable device for further analysis.

## License
This project is licensed under the Guardian app License. See the LICENSE file for more details.