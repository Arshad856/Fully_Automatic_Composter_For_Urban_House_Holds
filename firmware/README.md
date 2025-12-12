# Fully Automatic Organic Waste Composter (ESP32-S3) — `final-firmware.ino`

This repository contains the embedded firmware (`final-firmware.ino`) for a multi-chamber, IoT-enabled composting machine. The system reads environmental and level sensors, controls actuators (heater, exhaust, valves, doors, motors), and synchronizes state with **Firebase Realtime Database** for remote monitoring and control (e.g., via a mobile app).

---

## 1. Key Features

- Multi-chamber sensing:
  - Temperature (DS18B20 – 1-Wire)
  - Humidity & Temperature (DHT series)
  - Soil moisture (capacitive sensors)
  - Fill / level sensing (HC-SR04 ultrasonic)
- Actuator control via Firebase:
  - Doors (servo-driven)
  - Exhaust fans
  - Solenoid water valve
  - Heater / heater fan
  - Stirring / rotating motor
  - Shredder / grinder motor
- Non-blocking embedded control:
  - Time- and state-machine–based motor sequencing
  - Generic DoorNode-based servo control architecture

---

## 2. Firmware File

- **Main firmware:** `final-firmware.ino`

> **Note:** `final-firmware.ino` intentionally **does not include a complete DHT1 implementation**.  
> A `DHT1_PIN` macro may exist, but `dht1.begin()`, sensor reads, and Firebase uploads are **not implemented**.

---

## 3. Hardware Requirements

### Microcontroller
- ESP32-S3  
  (Firmware assumes ESP32 Arduino core support)

---

### Sensors (Typical)

- DS18B20 temperature sensors (1-Wire)
- DHT temperature/humidity sensors
- Capacitive soil moisture sensors
- HC-SR04 ultrasonic sensors (chamber level)

---

### Actuators (Typical)

- Servo motors (chamber doors)
- DC motor (stirring / rotation)
- Grinder / shredder motor
- Exhaust fans
- Solenoid water valve
- Heater or heater fan (relay / SSR / triac controlled)

---

## 4. Pin Configuration (ESP32-S3)

### 4.1 Sensor Pinout Table

| Sensor | Chamber / Purpose | MCU Pin(s) | Interface | Notes |
|------|------------------|-----------|----------|------|
| DHT (Temp/Humidity) | Chamber 1 | `DHT1_PIN = 4` | Digital | Defined only, **not implemented** |
| DHT (Temp/Humidity) | Chamber 2 | `DHT2_PIN = 37` | Digital | Active |
| DHT (Temp/Humidity) | Chamber 3 | `DHT3_PIN = 14` | Digital | Active |
| DHT (Temp/Humidity) | Chamber 4 | `DHT4_PIN = 16` | Digital | Active |
| Soil Moisture | Chamber 2 | `SOIL2 = 1` | ADC | ADC-capable pin required |
| Soil Moisture | Chamber 3 | `SOIL3 = 2` | ADC | ADC-capable pin required |
| Soil Moisture | Chamber 4 | `SOIL4 = 3` | ADC | ADC-capable pin required |
| DS18B20 Temperature | Chamber 2 | `GPIO 45` | 1-Wire | `oneWire2 → ds2` |
| DS18B20 Temperature | Chamber 3 | `GPIO 15` | 1-Wire | `oneWire3 → ds3` |
| Ultrasonic Level | Chamber 1 | `US1_TRIG = 47`, `US1_ECHO = 33` | Digital | Updated mapping |
| Ultrasonic Level | Chamber 4 | `US4_TRIG = 17`, `US4_ECHO = 18` | Digital | Stable |
| Power Detector | System power | `POWER_DETECTOR = 48` | Digital | Use divider / opto |
| Grinder Trigger Button | Manual input | `GRINDER_TRIG_BTN = 46` | Digital | Active-low |

---

### 4.2 Actuator Pinout Table

| Actuator | Chamber / Purpose | MCU Pin | Type | Notes |
|--------|------------------|--------|------|------|
| Door Servo | Chamber 1 | `SERVO1 = 39` | PWM | DoorNode-controlled |
| Door Servo | Chamber 2 | `SERVO2 = 40` | PWM | DoorNode-controlled |
| Door Servo | Chamber 3 | `SERVO3 = 41` | PWM | DoorNode-controlled |
| Door Servo | Chamber 4 | `SERVO4 = 42` | PWM | DoorNode-controlled |
| Exhaust Fan | Chamber 2 | `FAN2 = 35` | Digital | Relay-driven |
| Exhaust Fan | Chamber 3 | `FAN3 = 5` | Digital | Relay-driven |
| Exhaust Fan | Chamber 4 | `FAN4 = 6` | Digital | Relay-driven |
| Mixing Motor (Forward) | Main motor | `MOTOR_FWD = 19` | Digital | Direction |
| Mixing Motor (Reverse) | Main motor | `MOTOR_REV = 20` | Digital | Direction |
| Mixing Motor Enable | Main motor | `MOTOR_SWITCH = 36` | Digital | Master relay |
| Grinder Motor | Shredder | `GRINDING_MOTOR = 7` | Digital | Relay-driven |
| Heater / Heater Fan | Heating | `HEATER_FAN = 21` | Digital | Relay / SSR |
| Water Valve | Chamber 3 | `VALVE_3 = 38` | Digital | Solenoid valve |

---

### 4.3 Storage & Communication

| Function | MCU Pins | Notes |
|-------|---------|------|
| SD Card | `SD_CS = 10` | SPI bus assumed |
| I²C Bus | `SDA = 8`, `SCL = 9` | Defined in firmware |

---

## 5. Firebase Realtime Database Structure

The firmware reads/writes to Firebase paths similar to:

### Actuator Control Node

- `Actuator_Control/...`
  - `Chamber_1st/Door`
  - `Chamber_2nd/Door`, `Chamber_2nd/Exhaust`, `Chamber_2nd/Valve`
  - `Chamber_3rd/Door`, `Chamber_3rd/Exhaust`, `Chamber_3rd/Heater`, `Chamber_3rd/Valve`
  - `Chamber_4th/Door`, `Chamber_4th/Exhaust`

### Current Sensor Readings


`X` corresponds to the chamber number.
- `Current_Sensor_Reading/...`
  - `dhtx/Temperature`, `dhtx/Humidity`
  - `dsx_temperature`
  - `distanceX`
  - `Soil_Moisture/...` (as implemented)

---

## 6. Actuator Command Encoding

| Value | Meaning |
|-----:|--------|
| 0 | IDLE |
| 1 | OFF / Close |
| 2 | ON / Open / In |
| 3 | Out |

Used to maintain deterministic actuator behavior across firmware and mobile app.

---

## 7. Door Control Architecture (High-Level)

`final-firmware.ino` implements a **generic DoorNode state machine**:

- Open/close command issued from Firebase
- Non-blocking servo motion update
- Door state tracked as **OPEN / CLOSED / MOVING**

This approach scales cleanly for multi-door systems.

---

## 8. Build & Upload Instructions (Arduino IDE)

1. Install Arduino IDE
2. Install **ESP32 Board Package (Espressif)**
3. Select your ESP32-S3 board and COM port
4. Open `final-firmware.ino`
5. Configure:
   - Wi-Fi credentials
   - Firebase database URL & API key
6. Upload and monitor via Serial Monitor

---

## 9. Required Libraries

- ESP32 Arduino Core (WiFi)
- Firebase client library (used in firmware)
- Adafruit DHT Sensor library
- OneWire
- DallasTemperature
- ESP32-compatible Servo library (e.g., ESP32Servo)

Install exactly what is referenced in `#include` statements.

---

## 10. Runtime Verification Checklist

- Wi-Fi connects successfully
- Firebase read/write operations succeed
- Sensor values update periodically
- Actuator commands reflect correctly in hardware
- Ultrasonic sensors return stable distance values

---

## 11. Troubleshooting

### Wi-Fi Issues
- Verify SSID/password
- Check DNS/router availability

### Firebase Issues
- Verify database URL & API key
- Check Firebase rules

### Ultrasonic Noise
- Confirm correct TRIG/ECHO pins
- Use proper power & common ground

### Servo Jitter
- Use external servo power supply
- Ensure common ground with ESP32

---

## 12. Safety Notes

- Always use proper relays, SSRs, or drivers for high-current loads
- Isolate mains-powered heater circuits
- Ensure wiring and enclosure safety in humid environments

---

## 13. Project Context

Firmware developed for a **Fully Automatic Organic Waste Composter** as a final year engineering project, integrating embedded systems, IoT, and automation.

---

## 14. License

Specify your license here (MIT / Apache-2.0 / Proprietary).

