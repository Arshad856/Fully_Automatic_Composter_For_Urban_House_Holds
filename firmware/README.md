# Fully Automatic Organic Waste Composter (ESP32-S3) — `final-firmware.ino`

This repository contains the embedded firmware (`final-firmware.ino`) for a multi-chamber, IoT-enabled composting machine. The system reads environmental and level sensors, controls actuators (heater, exhaust, valves, doors, motors), and synchronizes state with **Firebase Realtime Database** for remote monitoring/control (e.g., via a mobile app).

---

## 1. Key Features

- Multi-chamber sensing:
  - Temperature (DS18B20)
  - Humidity/Temperature (DHT22 / DHTx as configured)
  - Soil moisture (capacitive sensors)
  - Fill/level sensing (HC-SR04 ultrasonic)
- Actuator control via Firebase:
  - Doors (servo-driven)
  - Exhaust fans
  - Solenoid water valves
  - Heater (relay/triac control depending on hardware)
  - Stirring / rotating motor
  - Shredder / grinder motor
- Non-blocking control approach:
  - Time/state-machine driven motor sequencing
  - Door control via a reusable “DoorNode” state update pattern

---

## 2. Firmware File

- **Main firmware:** `final.ino`

> Note: `final.ino` intentionally **does not** include a complete DHT1 implementation. A `DHT1_PIN` macro may exist, but `dht1.begin()` / read / upload logic is not present in `final.ino`.

---

## 3. Hardware Requirements

### Microcontroller
- ESP32-S3 (recommended; firmware assumes ESP32-class Arduino support)

### Sensors (typical)
- DS18B20 temperature sensors (1-Wire)
- DHT22 temperature/humidity sensor(s)
- Capacitive soil moisture sensors
- HC-SR04 ultrasonic sensors (for chamber level)

### Actuators (typical)
- Servo motors for doors
- DC motor(s) for mixing/rotation
- Grinder/shredder motor
- Exhaust fan(s)
- Solenoid valve(s)
- Heater control (relay/SSR/triac module depending on design)

---

## 4. Pin Configuration Notes (Important)

`final.ino` uses specific pin mappings. Verify your wiring matches the definitions in the file.

### Ultrasonic (Chamber 1 mapping changed)
In `final.ino`:
- `US1_TRIG` = **47**
- `US1_ECHO` = **33**

This change avoids pin conflicts present in older variants where US1 and US4 could share pins.

> Always confirm your ESP32-S3 board variant supports the selected GPIOs.

---

## 5. Firebase Realtime Database Structure

The firmware reads/writes to Firebase paths similar to the following (names may vary slightly depending on your UI/app):

### Actuator Control Node
`Actuator_Control/`

Example chamber mapping:
- `Chamber_1st/Door`
- `Chamber_2nd/Door`, `Chamber_2nd/Exhaust`, `Chamber_2nd/Valve`
- `Chamber_3rd/Door`, `Chamber_3rd/Exhaust`, `Chamber_3rd/Heater`, `Chamber_3rd/Valve`
- `Chamber_4th/Door`, `Chamber_4th/Exhaust`

### Current Sensor Readings
Common pattern:
`Current_Sensor_Reading/`

Example:
- `dhtx/Temperature`
- `dhtx/Humidity`
- `dsx_temperature`
- `distanceX`

Where `X` corresponds to chamber index.

---

## 6. Actuator Command Encoding

The firmware expects discrete integer commands for actuator state:

- `0` = IDLE
- `1` = OFF / Close
- `2` = ON / Open / In
- `3` = Out

(Used for consistent UI/app control and deterministic actuator behavior.)

---

## 7. How Door Control Works (High Level)

`final.ino` implements door handling using a reusable state-machine style approach:

- A command request is issued (open/close)
- The door update routine advances servo motion without blocking
- A status method provides the current state (moving/open/closed)

This approach is more scalable than per-door “one-off” logic and is recommended for multiple servo doors.

---

## 8. Build & Upload Instructions (Arduino IDE)

1. Install Arduino IDE.
2. Install **ESP32 board support** (Espressif).
3. Select your board (ESP32-S3 variant) and COM port.
4. Open `final.ino`.
5. Configure credentials:
   - Wi-Fi SSID / Password
   - Firebase host / API key / database URL (as defined in code)
6. Upload.

> If you use PlatformIO, replicate the same library dependencies and board settings.

---

## 9. Required Libraries

The firmware uses typical Arduino/ESP32 libraries such as:
- WiFi (ESP32 core)
- Firebase client library (as used in your codebase)
- DHT sensor library (Adafruit DHT or equivalent)
- OneWire + DallasTemperature (for DS18B20)
- Servo library compatible with ESP32 (or ESP32Servo)

Install the exact libraries referenced by your `#include` statements in `final.ino`.

---

## 10. Runtime Verification Checklist

After flashing:
- Serial Monitor shows Wi-Fi connect status and Firebase connectivity.
- Sensor values update periodically.
- Actuator commands sent in Firebase reflect on hardware (doors, fans, valve, heater, motors).
- Ultrasonic readings are stable and mapped to the correct chamber.

---

## 11. Troubleshooting

### Wi-Fi connection fails
- Confirm SSID/password.
- Check DNS/network availability on the router.
- If you see host resolution errors, verify network DNS is working.

### Firebase reads/writes not working
- Confirm database URL and API key.
- Check Firebase rules (read/write permissions).
- Verify correct node paths in both app and firmware.

### Ultrasonic gives zeros / noise
- Confirm TRIG/ECHO wiring and shared ground.
- Avoid powering HC-SR04 directly from 3.3V if unstable (use proper power and level shifting if required).
- Ensure the GPIO pins match `final.ino` definitions (US1 uses 47/33).

### Door/Servo jitter
- Use separate power supply for servos (do not power servos from ESP32 5V pin if current is high).
- Common ground between servo PSU and ESP32 is required.

---

## 12. Safety Notes

- Motors, heaters, and high-current loads must be driven via proper relays/SSRs/driver circuits.
- Use fuses and proper isolation (especially for mains-powered heaters).
- Ensure enclosures and wiring are safe for humid environments.

---

## 13. Authors / Project Context

Firmware for a **Fully Automatic Organic Waste Composter** (multi-chamber, IoT-enabled) developed as a final year project.

---

## 14. License

Specify your license here (MIT/Apache-2.0/Proprietary) depending on your repository policy.

