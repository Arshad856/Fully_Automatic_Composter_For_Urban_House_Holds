# Fully Automatic Organic Waste Composter (ESP32-S3) — `final-firmware.ino`

This repository contains the embedded firmware (`final-firmware.ino`) for a multi-chamber, IoT-enabled composting machine. The system reads environmental and level sensors, controls actuators (heater, exhaust, valves, doors, motors), and synchronizes state with Firebase Realtime Database for remote monitoring/control (e.g., via a mobile app).

---

## 1. Key Features

- Multi-chamber sensing:
  - Temperature (DS18B20 / 1-Wire)
  - Humidity/Temperature (DHT series)
  - Soil moisture (capacitive sensors)
  - Fill/level sensing (HC-SR04 ultrasonic)
- Actuator control:
  - Doors (servo-driven)
  - Exhaust fans
  - Solenoid water valve (as implemented)
  - Heater / heater fan (as implemented)
  - Stirring / rotating motor (direction + enable logic)
  - Shredder / grinder motor
- Non-blocking control approach:
  - Time/state-machine driven motor sequencing
  - Door control via a reusable DoorNode update pattern

---

## 2. Firmware File

- **Main firmware:** `final-firmware.ino`

> Note: `final-firmware.ino` intentionally **does not** include a complete DHT1 implementation. A `DHT1_PIN` macro may exist, but `dht1.begin()` / read / upload logic is not present.

---

## 3. Hardware Requirements

### Microcontroller
- ESP32-S3 (recommended)

---

## 4. Pinouts

### 4.1 Sensors (Pin Map)

| Sensor / Signal | Chamber / Purpose | MCU Pin(s) | Interface | Notes |
|---|---:|---:|---|---|
| DHT (Temp/Humidity) | Chamber 2 | `DHT2_PIN = 37` | Digital | Used in firmware |
| DHT (Temp/Humidity) | Chamber 3 | `DHT3_PIN = 14` | Digital | Used in firmware |
| DHT (Temp/Humidity) | Chamber 4 | `DHT4_PIN = 16` | Digital | Used in firmware |
| DHT (Temp/Humidity) | Chamber 1 | `DHT1_PIN = 4` | Digital | Defined, not fully implemented |
| Soil moisture | Chamber 2 | `SOIL2 = 1` | ADC | ESP32-S3 ADC pin |
| Soil moisture | Chamber 3 | `SOIL3 = 2` | ADC | ESP32-S3 ADC pin |
| Soil moisture | Chamber 4 | `SOIL4 = 3` | ADC | ESP32-S3 ADC pin |
| DS18B20 temperature | Chamber 2 | `GPIO 45` | 1-Wire | `oneWire2 → ds2` |
| DS18B20 temperature | Chamber 3 | `GPIO 15` | 1-Wire | `oneWire3 → ds3` |
| Ultrasonic (HC-SR04) | Chamber 1 | `US1_TRIG = 47`, `US1_ECHO = 33` | Digital | Updated mapping |
| Ultrasonic (HC-SR04) | Chamber 4 | `US4_TRIG = 17`, `US4_ECHO = 18` | Digital | Level sensing |
| Power detector | Supply status | `POWER_DETECTOR = 48` | Digital | Use divider/opto |
| Grinder trigger button | Manual input | `GRINDER_TRIG_BTN = 46` | Digital | Active-low button |

---

### 4.2 Actuators (Pin Map)

| Actuator | Chamber / Purpose | MCU Pin(s) | Type | Notes |
|---|---:|---:|---|---|
| Door servo | Chamber 1 | `SERVO1 = 39` | PWM | DoorNode control |
| Door servo | Chamber 2 | `SERVO2 = 40` | PWM | DoorNode control |
| Door servo | Chamber 3 | `SERVO3 = 41` | PWM | DoorNode control |
| Door servo | Chamber 4 | `SERVO4 = 42` | PWM | DoorNode control |
| Exhaust fan | Chamber 2 | `FAN2 = 35` | Digital | Relay driven |
| Exhaust fan | Chamber 3 | `FAN3 = 5` | Digital | Relay driven |
| Exhaust fan | Chamber 4 | `FAN4 = 6` | Digital | Relay driven |
| Motor forward | Mixer motor | `MOTOR_FWD = 19` | Digital | Direction |
| Motor reverse | Mixer motor | `MOTOR_REV = 20` | Digital | Direction |
| Motor enable | Mixer motor | `MOTOR_SWITCH = 36` | Digital | Enable relay |
| Grinder motor | Shredder | `GRINDING_MOTOR = 7` | Digital | Relay driven |
| Heater / fan | Heating | `HEATER_FAN = 21` | Digital | Relay/SSR |
| Water valve | Chamber 3 | `VALVE_3 = 38` | Digital | Solenoid valve |

---

## 5. Actuator Command Encoding

| Value | Meaning |
|---:|---|
| 0 | IDLE |
| 1 | OFF / Close |
| 2 | ON / Open / In |
| 3 | Out |

---

## 6. Build & Upload

1. Open Arduino IDE  
2. Select ESP32-S3 board  
3. Open `final-firmware.ino`  
4. Configure Wi-Fi & Firebase credentials  
5. Upload and monitor via Serial Monitor  

---

## 7. Safety Notes

- Motors, heaters, and solenoids **must** use proper drivers/relays.
- Use isolated supplies for servos and motors.
- Common ground is required.

---

## 8. License

Specify your license (MIT / Apache-2.0 / Proprietary).
