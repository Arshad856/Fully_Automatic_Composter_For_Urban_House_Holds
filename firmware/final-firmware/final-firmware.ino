#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <FirebaseClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DHT.h>
#include <SD.h>
#include <time.h>
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>

// WiFi Credentials
const char* ssid = "Arshad";
const char* password = "Ars321.ml";

// NTP Client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 19800, 60000);  // GMT+5:30
time_t lastUploadTime = 0;
const unsigned long uploadInterval = 120; // seconds

// LCD: 16x2, I2C address 0x27 (change to 0x3F if needed)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Day and Month names
const char* monthNames[] = {
  "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
};

const char* dayNames[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

// Firebase Credentials
#define API_KEY         "AIzaSyDUy0wFzo6cf3KleahCa_JY0UDoWn4pRJI"
#define USER_EMAIL      "arshad987.mla@gmail.com"
#define USER_PASSWORD   "Ars321.mla"
#define DATABASE_URL    "https://composter-fyp-default-rtdb.asia-southeast1.firebasedatabase.app/"

// Firebase Objects
DefaultNetwork network;
UserAuth user_auth(API_KEY, USER_EMAIL, USER_PASSWORD);
FirebaseApp app;
WiFiClientSecure ssl_client;
using AsyncClient = AsyncClientClass;
AsyncClient aClient(ssl_client, getNetwork(network));
RealtimeDatabase Database;
AsyncResult aResult_no_callback;
int update = 0;

// SD Card
#define SD_CS 10

// DHT22 Pins
#define DHT1_PIN 4
#define DHT2_PIN 37
#define DHT3_PIN 14
#define DHT4_PIN 16
DHT dht2(DHT2_PIN, DHT22);
DHT dht3(DHT3_PIN, DHT22);
DHT dht4(DHT4_PIN, DHT22);

// DS18B20
OneWire oneWire2(45);
OneWire oneWire3(15);
DallasTemperature ds2(&oneWire2);
DallasTemperature ds3(&oneWire3);

// Soil Moisture Pins
#define SOIL2 1
#define SOIL3 2
#define SOIL4 3

// Ultrasonic Pins
#define SOUND_SPEED 0.034
#define US1_TRIG 47
#define US1_ECHO 33
#define US4_TRIG 17
#define US4_ECHO 18


// Relays
#define FAN2 35
#define FAN3 5
#define FAN4 6
#define MOTOR_FWD 19
#define MOTOR_REV 20
#define MOTOR_SWITCH 36
#define GRINDING_MOTOR 7
#define HEATER_FAN 21
#define VALVE_3 38
#define POWER_DETECTOR 48

//Push Button
#define GRINDER_TRIG_BTN 46

// Servo Pins
#define SERVO1 39
#define SERVO2 40
#define SERVO3 41
#define SERVO4 42

// I2C Pins (used in Wire.begin, not defined with #define)
#define I2C_SDA 8
#define I2C_SCL 9


// Global actuator control variables (updated structure)
int door1_state = 0;

int door2_state = 0;
int exhaust2_state = 0;

int door3_state = 0;
int exhaust3_state = 0;
int valve3_state = 0;
int heater3_state = 0;
int heater_fan_state = 0;

int door4_state = 0;
int exhaust4_state = 0;
int turning_state = 0;

// Put these at file scope (top of file)
static unsigned long door_lastCheck = 0;
static int door_1_status = -1;
static bool door1_open_cmd_sent = false;
static bool door1_close_cmd_sent = false;
static int last_door1_cmd = 0;


enum MotorState { IDLE, SETUP, WAIT_DIR_CLEAR, SET_DIRECTION, WAIT_START, ENABLE_MOTOR };
// -------- Public API --------
enum DoorState : uint8_t { DOOR_CLOSE = 0, DOOR_OPEN = 1 };
MotorState motorState = IDLE;

int rotation_state = 0;
int rotation_counter = 0;

String currentDirection = "";
// New
time_t motorStartEpoch = 0;
bool motorRequested = false;

int lcdColumns = 16;
int lcdRows = 2;

// ---------- Motor polarity ----------
const uint8_t MOTOR_ON  = LOW;   // active-low relay
const uint8_t MOTOR_OFF = HIGH;

// ---------- Button logic ----------
const int BUTTON_ACTIVE = HIGH;  // HIGH = pressed in your wiring
const int BUTTON_IDLE   = LOW;

// ---------- Timing (ms) ----------
const unsigned long HOLD_MS     = 3000;  // hold to trigger
const unsigned long RUN_MS      = 3000;  // motor run time
const unsigned long DEBOUNCE_MS = 50;

// ---------- State variables ----------
int lastReading = BUTTON_IDLE;
int stableState = BUTTON_IDLE;
unsigned long lastDebounceMs = 0;

bool armed = true;
bool motorRunning = false;
unsigned long pressStartMs = 0;
unsigned long motorOnMs = 0;

// ---------- Grinder handler ----------
void handleGrinder() {
  // Update NTP time (optional)
  timeClient.update();

  // Debounce
  int reading = digitalRead(GRINDER_TRIG_BTN);
  if (reading != lastReading) {
    lastDebounceMs = millis();
  }
  if (millis() - lastDebounceMs > DEBOUNCE_MS) {
    if (reading != stableState) {
      stableState = reading;
      if (stableState == BUTTON_ACTIVE) {
        if (armed && pressStartMs == 0) {
          pressStartMs = millis();
          Serial.println("[BTN] Pressed (debounced). Starting hold timer.");
        }
      } else {
        armed = true;
        pressStartMs = 0;
        Serial.println("[BTN] Released. System re-armed.");
      }
    }
  }
  lastReading = reading;

  // Approve motor start after hold
  if (armed && pressStartMs != 0 && (millis() - pressStartMs >= HOLD_MS) && !motorRunning) {
    armed = false;
    pressStartMs = 0;
    digitalWrite(GRINDING_MOTOR, MOTOR_ON);
    motorOnMs = millis();
    motorRunning = true;
    Serial.println("[MOTOR] ON (approved after 3s hold).");
    printClock();
  }

  // Stop motor after run time
  if (motorRunning && (millis() - motorOnMs >= RUN_MS)) {
    digitalWrite(GRINDING_MOTOR, MOTOR_OFF);
    motorRunning = false;
    Serial.println("[MOTOR] OFF (3s elapsed).");
    printClock();
  }
}

// ---------- Time print helper ----------
void printClock() {
  unsigned long epoch = timeClient.getEpochTime();
  int hour   = (epoch % 86400UL) / 3600;
  int minute = (epoch % 3600) / 60;
  int second = epoch % 60;
  char buf[24];
  snprintf(buf, sizeof(buf), "[TIME] %02d:%02d:%02d", hour, minute, second);
  Serial.println(buf);
}

// ===== Angles (edit as you like; note: close > open) =====
uint8_t servo1_openAngle = 65, servo1_closeAngle = 88;
uint8_t servo2_openAngle = 46, servo2_closeAngle = 73;
uint8_t servo3_openAngle = 35, servo3_closeAngle = 74;
uint8_t servo4_openAngle = 35, servo4_closeAngle = 67;

// ===== Servo objects =====
Servo servo1, servo2, servo3, servo4;



// Request a door move (lazily attaches the servo the first time you use a pin)
void doorCommand(uint8_t pin,
                 DoorState state,
                 uint8_t openAngle,
                 uint8_t closeAngle,
                 uint8_t stepSize = 1,
                 unsigned long stepIntervalMs = 15);

// Call this once per loop() to advance all in-progress motions
void doorUpdate();


// ===== Implementation (drop-in) =====
struct DoorNode {
  uint8_t pin = 0xFF;
  Servo servo;
  bool attached = false;

  uint8_t current = 90;
  uint8_t target  = 90;

  uint8_t openAngle  = 60;
  uint8_t closeAngle = 90;

  uint8_t stepSize = 1;
  unsigned long stepIntervalMs = 15;
  unsigned long lastStepMs = 0;

  bool moving = false;
};

static inline uint8_t clampAngle(int v) {
  if (v < 0)   return 0;
  if (v > 180) return 180;
  return (uint8_t)v;
}

#ifndef DOOR_MAX
#define DOOR_MAX 12   // up to 12 unique pins tracked; change if needed
#endif

static DoorNode _doors[DOOR_MAX];

static int _findNode(uint8_t pin) {
  for (int i = 0; i < DOOR_MAX; ++i) {
    if (_doors[i].attached && _doors[i].pin == pin) return i;
  }
  return -1;
}

static int _allocNode(uint8_t pin) {
  // return existing if found
  int idx = _findNode(pin);
  if (idx >= 0) return idx;

  // find a free slot
  for (int i = 0; i < DOOR_MAX; ++i) {
    if (!_doors[i].attached && _doors[i].pin == 0xFF) {
      _doors[i].pin = pin;
      // set standard servo timing for ESP32-S3
      _doors[i].servo.setPeriodHertz(50);
      _doors[i].servo.attach(pin, 500, 2400);

      _doors[i].attached = true;
      _doors[i].current = 90;
      _doors[i].target  = 90;
      _doors[i].lastStepMs = 0;
      //_doors[i].servo.write(_doors[i].current);
      return i;
    }
  }
  return -1; // no space
}

void doorCommand(uint8_t pin,
                 DoorState state,
                 uint8_t openAngle,
                 uint8_t closeAngle,
                 uint8_t stepSize,
                 unsigned long stepIntervalMs)
{
  int idx = _allocNode(pin);
  if (idx < 0) return;

  DoorNode& d = _doors[idx];
  d.openAngle  = clampAngle(openAngle);
  d.closeAngle = clampAngle(closeAngle);
  d.stepSize   = (stepSize == 0) ? 1 : stepSize;
  d.stepIntervalMs = (stepIntervalMs == 0) ? 1 : stepIntervalMs;

  uint8_t newTarget = (state == DOOR_OPEN) ? d.openAngle : d.closeAngle;

  // Only (re)start stepping if target changed or we were idle
  if (d.target != newTarget || !d.moving) {
    d.target = newTarget;
    d.moving = true;
    d.lastStepMs = millis();
  }
}


void doorUpdate() {
  unsigned long now = millis();
  for (int i = 0; i < DOOR_MAX; ++i) {
    DoorNode& d = _doors[i];
    if (!d.attached || !d.moving) continue;

    if (now - d.lastStepMs >= d.stepIntervalMs) {
      d.lastStepMs = now;

      if (d.current == d.target) {
        d.moving = false;
        continue;
      }

      int step = (d.target > d.current) ? d.stepSize : -(int)d.stepSize;
      int next = (int)d.current + step;

      // avoid overshoot
      if ((step > 0 && next > d.target) || (step < 0 && next < d.target)) {
        next = d.target;
      }

      d.current = clampAngle(next);
      d.servo.write(d.current);
    }
  }
}

// Returns: 0 = moving, 1 = fully open, 2 = fully closed, -1 = pin not found
int doorStatus(uint8_t pin) {
  int idx = _findNode(pin);
  if (idx < 0) return -1; // not in our list yet

  DoorNode& d = _doors[idx];
  if (d.moving) return 0; // still moving
  if (d.current == d.openAngle)  return 1; // fully open
  if (d.current == d.closeAngle) return 2; // fully closed
  return -1; // unknown (might be at a mid-position)
}



void setup() {
  Serial.begin(115200);

  dht2.begin(); dht3.begin(); dht4.begin();
  ds2.begin(); ds3.begin();

  pinMode(US1_TRIG, OUTPUT); pinMode(US1_ECHO, INPUT);
  pinMode(US4_TRIG, OUTPUT); pinMode(US4_ECHO, INPUT);


  // Motor pin setup
  pinMode(MOTOR_FWD, OUTPUT);
  pinMode(MOTOR_REV, OUTPUT);
  pinMode(MOTOR_SWITCH, OUTPUT);
  pinMode(FAN2, OUTPUT);
  pinMode(FAN3, OUTPUT);
  pinMode(FAN4, OUTPUT);
  digitalWrite(MOTOR_FWD, HIGH);
  digitalWrite(MOTOR_REV, HIGH);
  digitalWrite(MOTOR_SWITCH, HIGH);
  digitalWrite(FAN2, HIGH);
  digitalWrite(FAN3, HIGH);
  digitalWrite(FAN4, HIGH);
  digitalWrite(HEATER_FAN, HIGH);
  digitalWrite(GRINDING_MOTOR, MOTOR_OFF);


  
    lcd.init();
  lcd.backlight();

    // Connect to SD
  lcd.setCursor(0, 0);
  lcd.print("Initializing SD");


  // SD Card
  if (!SD.begin(SD_CS)) {
    Serial.println("SD Card failed!");
      // Connect to SD
  lcd.setCursor(0, 0);
  lcd.print("SD Card failed!");
    while (1);
  }
  Serial.println("SD Card initialized.");
  lcd.setCursor(0, 0);
  lcd.print("SD InitiaLized!");

  delay(1000);
  

  // Connect to WiFi
  lcd.setCursor(0, 0);
  lcd.print("Connecting WiFi");

  // Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.println("\nWiFi Connected.");

  lcd.clear();
  lcd.print("WiFi Connected!");
  delay(1500);
  lcd.clear();

  // NTP
  timeClient.begin();
  Serial.println("NTP Begin");
  while (!timeClient.update()) timeClient.forceUpdate();

  
  // Firebase
  ssl_client.setInsecure();
  initializeApp(aClient, app, getAuth(user_auth), aResult_no_callback);
  while (app.isInitialized() && !app.ready()) {
    JWT.loop(app.getAuth());
    delay(100);
  }
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);

  // Firebase listener
  Database.get(aClient, "/Update", [](AsyncResult &aResult) {
    if (aResult.available()) {
      RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();
      if (RTDB.isStream() && RTDB.type() == 1 && RTDB.dataPath().length()) {
        update = RTDB.to<int>();
        Serial.printf("Firebase Update Triggered: %d\n", update);
      }
    }
  }, true, "monitorUpdate");
}

unsigned long lastSensorRead = 0;
const unsigned long sensorInterval = 5000; // 2 seconds

void loop() {
  app.loop();
  JWT.loop(app.getAuth());
  Database.loop();
  timeClient.update();

  doorUpdate();

  time_t currentTime = timeClient.getEpochTime();

  if (update != 0) {
    renameAndCreateNewLog();
    checkAndUpdateActuators();
    if (door1_state != last_door1_cmd) {
  door1_open_cmd_sent  = false;
  door1_close_cmd_sent = false;
  last_door1_cmd = door1_state;
}
    Serial.print("Turning State is: ");
    Serial.println(turning_state);
    Database.set<int>(aClient, "/Update", 0);
    update = 0;
  }

//unsigned long currentime = millis();
  if (currentTime - lastSensorRead >= sensorInterval) {
    ds2.requestTemperatures(); float temp_ds2 = ds2.getTempCByIndex(0);
    ds3.requestTemperatures(); float temp_ds3 = ds3.getTempCByIndex(0);
    float t2 = dht2.readTemperature(), h2 = dht2.readHumidity();
    float t3 = dht3.readTemperature(), h3 = dht3.readHumidity();
    float t4 = dht4.readTemperature(), h4 = dht4.readHumidity();
    float dist1 = readUltrasonicCM(US1_TRIG, US1_ECHO);
    float dist4 = readUltrasonicCM(US4_TRIG, US4_ECHO);
    float soil2 = getSoilMoisturePercentage(2960, 1231, analogRead(SOIL2));
    float soil3 = getSoilMoisturePercentage(2999, 1737, analogRead(SOIL3));
    float soil4 = getSoilMoisturePercentage(2968, 1260, analogRead(SOIL4));
    logSensorDataToSD(temp_ds2, temp_ds3, t2, h2, t3, h3, t4, h4, soil2, soil3, soil4, dist1, dist4);
    lastSensorRead = currentTime;
  }

  // Upload every 120 seconds
  if (currentTime - lastUploadTime >= uploadInterval) {
    uploadAllSensorDataToFirebase();
    lastUploadTime = currentTime;
  }

  // Get the current time in seconds since epoch
  unsigned long epochTime = timeClient.getEpochTime();
  
  // Extract hours, minutes, and seconds
  int hour = (epochTime % 86400L) / 3600;       // Extract hours
  int minute = (epochTime % 3600) / 60;          // Extract minutes
  int second = epochTime % 60;                   // Extract seconds
  
  // Combine hours, minutes, and seconds as a single integer (HHMMSS)
  int timeInt = hour * 10000 + minute * 100 + second;

  char TimeBuffer[20];
  sprintf(TimeBuffer, "Time: %02d:%02d:%02d", hour, minute, second);  

    Serial.print("Turning_State: ");
  Serial.println(turning_state);
  Serial.print("Rotating_State: ");
  Serial.println(rotation_state);

  //Serial.print("Date Int: ");
  Serial.println(TimeBuffer);

  // Convert to tm structure
time_t rawTime = (time_t)epochTime;
struct tm *timeinfo = localtime(&rawTime);  // Use gmtime() if you want UTC

int day   = timeinfo->tm_mday;     // Day of month (1–31)
int month = timeinfo->tm_mon + 1;  // Months since January (0–11) → +1 to make it 1–12
int year  = timeinfo->tm_year + 1900; // Years since 1900 → +1900 to get actual year
int wday = timeinfo->tm_wday;
// Print formatted date
char dateStr[20];
sprintf(dateStr, "%s, %02d %s", dayNames[wday],day, monthNames[month-1]);  // e.g., "01/08/2025"
Serial.println(dateStr);

lcd.setCursor(0,1);
lcd.print(dateStr);
lcd.setCursor(0,0);
lcd.print(TimeBuffer);
 

   if ((turning_state <= 1) && (rotation_state == 2)){
    turning_state = 0;
    rotation_state = 0;
  }
  if ((turning_state > 1) && (rotation_state == 4)){
    turning_state = 0;
    rotation_state = 0;
  }

  //rotateMotor(turning_state, timeInt);

  uint32_t nowSec = timeClient.getEpochTime();
rotateMotor(turning_state, nowSec);


  if (exhaust2_state == 2){
    digitalWrite(FAN2, LOW);
    logActuatorDataToSD("FAN2", "LOW");
  }
  else if (exhaust2_state == 1){
    digitalWrite(FAN2, HIGH);
    logActuatorDataToSD("FAN2", "HIGH");
  }

  if (exhaust3_state == 2){
    digitalWrite(FAN3, LOW);
    logActuatorDataToSD("FAN3", "LOW");
  }
  else if (exhaust3_state == 1){
    digitalWrite(FAN3, HIGH);
    logActuatorDataToSD("FAN3", "HIGH");
  }

  if (exhaust4_state == 2){
    digitalWrite(FAN4, LOW);
    logActuatorDataToSD("FAN4", "LOW");
  }
  else if (exhaust4_state == 1){
    digitalWrite(FAN4, HIGH);
    logActuatorDataToSD("FAN4", "HIGH");
  }

   if (valve3_state == 2){
    digitalWrite(VALVE_3, LOW);
    logActuatorDataToSD("VALVE_3", "LOW");
  }
  else if (valve3_state == 1){
    digitalWrite(VALVE_3, HIGH);
    logActuatorDataToSD("VALVE_3", "HIGH");
  }

  if (valve3_state == 2){
    digitalWrite(HEATER_FAN, LOW);
    logActuatorDataToSD("HEATER_FAN", "LOW");
  }
  else if (HEATER_FAN == 1){
    digitalWrite(HEATER_FAN, HIGH);
    logActuatorDataToSD("HEATER_FAN", "HIGH");
  }

  // Poll status every ~500 ms
if (millis() - door_lastCheck >= 500) {
  door_lastCheck = millis();
  door_1_status = doorStatus(SERVO1);
  switch (door_1_status) {
    case 0: Serial.println("Door 01 is MOVING"); break;
    case 1: Serial.println("Door 01 is OPEN");   brea
    case 2: Serial.println("Door 01 is CLOSED"); break;
    default: Serial.println("Door 01 UNKNOWN");  break;
  }
}

// ---- CLOSE request ----
if (door1_state == 1 && !door1_close_cmd_sent) {
  doorCommand(SERVO1, DOOR_CLOSE, servo1_openAngle, servo1_closeAngle);
  door1_close_cmd_sent = true;
  door1_open_cmd_sent = false;   // cancel any previous open attempt
}
if (door_1_status == 2) {        // fully closed
  door1_state = 0;               // clear request
  door1_close_cmd_sent = false;  // ready for next time
}

// ---- OPEN request ----
if (door1_state == 2 && !door1_open_cmd_sent) {
  doorCommand(SERVO1, DOOR_OPEN, servo1_openAngle, servo1_closeAngle);
  door1_open_cmd_sent = true;
  door1_close_cmd_sent = false;  // cancel any previous close attempt
}
if (door_1_status == 1) {        // fully open
  door1_state = 0;
  door1_open_cmd_sent = false;
}




  // Get current time from NTP
  time_t now = time(nullptr);
  struct tm* timeinf = localtime(&now);
  int currentTimeInt = (timeinf->tm_hour * 10000) + (timeinf->tm_min * 100) + timeinf->tm_sec;

  int currentDateInt = (timeinf->tm_mday * 1000000) + ((timeinf->tm_mon + 1) * 10000) + (1900 + timeinf->tm_year);

  


}

float getSoilMoisturePercentage(int dry, int wet, int reading) {
  reading = constrain(reading, wet, dry);
  return ((float)(dry - reading) / (dry - wet)) * 100.0;
}

float readUltrasonicCM(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW); delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH, 30000);
  return duration ? duration * SOUND_SPEED / 2.0 : -1;
}

void logSensorDataToSD(float ds2, float ds3,
                       float t2, float h2, float t3, float h3, float t4, float h4,
                       float s2, float s3, float s4,
                       float d1, float d4) {
  timeClient.update();
  time_t now = timeClient.getEpochTime();
  struct tm *timeInfo = localtime(&now);
  char dateBuffer[7], timeBuffer[7];
  strftime(dateBuffer, sizeof(dateBuffer), "%d%m%y", timeInfo);
  strftime(timeBuffer, sizeof(timeBuffer), "%H%M%S", timeInfo);
  String dateStr = String(dateBuffer);
  String timeStr = String(timeBuffer);

  File sensor_log = SD.open("/sensor_log.txt", FILE_APPEND);
  if (!sensor_log) {
    Serial.println("Failed to open sensor_log.txt");
    return;
  }

  sensor_log.printf("%s %s - TEMP_DS2: %.2f°C\n", dateStr.c_str(), timeStr.c_str(), ds2);
  sensor_log.printf("%s %s - TEMP_DS3: %.2f°C\n", dateStr.c_str(), timeStr.c_str(), ds3);
  sensor_log.printf("%s %s - DHT2_T: %.2f°C H: %.2f%%\n", dateStr.c_str(), timeStr.c_str(), t2, h2);
  sensor_log.printf("%s %s - DHT3_T: %.2f°C H: %.2f%%\n", dateStr.c_str(), timeStr.c_str(), t3, h3);
  sensor_log.printf("%s %s - DHT4_T: %.2f°C H: %.2f%%\n", dateStr.c_str(), timeStr.c_str(), t4, h4);
  sensor_log.printf("%s %s - Soil2: %.2f%% Soil3: %.2f%% Soil4: %.2f%%\n", dateStr.c_str(), timeStr.c_str(), s2, s3, s4);
  sensor_log.printf("%s %s - Distance1: %.2fcm Distance4: %.2fcm\n\n", dateStr.c_str(), timeStr.c_str(), d1, d4);
  sensor_log.close();

  Serial.println("Sensor data saved to SD.");

  Serial.println("======== Actuator Status ========");

// Chamber 1
Serial.printf("Chamber 1st: Door = %d\n", door1_state);

// Chamber 2
Serial.printf("Chamber 2nd: Door = %d, Exhaust = %d\n",
              door2_state, exhaust2_state);

// Chamber 3
Serial.printf("Chamber 3rd: Door = %d, Exhaust = %d, Valve = %d, Heater = %d\n",
              door3_state, exhaust3_state, valve3_state, heater3_state);

// Chamber 4
Serial.printf("Chamber 4th: Door = %d, Exhaust = %d, Turning = %d\n",
              door4_state, exhaust4_state, turning_state);

Serial.println("=================================");

}

void logActuatorDataToSD(String Actuator_Name, String Actuator_Status) {
  timeClient.update();
  time_t now = timeClient.getEpochTime();
  struct tm *timeInfo = localtime(&now);
  char dateBuffer[7], timeBuffer[7];
  strftime(dateBuffer, sizeof(dateBuffer), "%d%m%y", timeInfo);
  strftime(timeBuffer, sizeof(timeBuffer), "%H%M%S", timeInfo);
  String dateStr = String(dateBuffer);
  String timeStr = String(timeBuffer);

  File sensor_log = SD.open("/Actuator_log.txt", FILE_APPEND);
  if (!sensor_log) {
    Serial.println("Failed to open Actuator_log.txt");
    return;
  }

  sensor_log.printf("%s %s - %s: %s\n", dateStr.c_str(), timeStr.c_str(), Actuator_Name,Actuator_Status);
  sensor_log.close();

  Serial.println("Actuator data saved to SD.");

  Serial.println("======== Actuator Status ========");

// Chamber 1
Serial.printf("Chamber 1st: Door = %d\n", door1_state);

// Chamber 2
Serial.printf("Chamber 2nd: Door = %d, Exhaust = %d\n",
              door2_state, exhaust2_state);

// Chamber 3
Serial.printf("Chamber 3rd: Door = %d, Exhaust = %d, Valve = %d, Heater = %d\n",
              door3_state, exhaust3_state, valve3_state, heater3_state);

// Chamber 4
Serial.printf("Chamber 4th: Door = %d, Exhaust = %d, Turning = %d\n",
              door4_state, exhaust4_state, turning_state);

Serial.println("=================================");

}

void renameAndCreateNewLog() {
  const char* currentLog = "/sensor_log.txt";

  if (!SD.exists(currentLog)) {
    Serial.println("[SD] No log file found to rename.");
    return;
  }

  // Get current time
  timeClient.update();
  time_t now = timeClient.getEpochTime();
  struct tm *timeInfo = localtime(&now);

  // Format date and time to strings
  char dateBuffer[7];  // ddmmyy
  char timeBuffer[7];  // HHMMSS
  strftime(dateBuffer, sizeof(dateBuffer), "%d%m%y", timeInfo);
  strftime(timeBuffer, sizeof(timeBuffer), "%H%M%S", timeInfo);

  // Format new backup filename
  char backupName[40];
  snprintf(backupName, sizeof(backupName),
           "/sensor_log_backup_%s_%s.txt",
           dateBuffer,
           timeBuffer);

  // Rename the existing log
  if (SD.rename(currentLog, backupName)) {
    Serial.printf("[SD] Log file renamed to: %s\n", backupName);
  } else {
    Serial.println("[SD] Rename failed.");
    return;
  }

  // Create a new sensor_log.txt file
  File newLog = SD.open(currentLog, FILE_WRITE);
  if (newLog) {
    newLog.println("=== New Sensor Log Started ===");
    newLog.close();
    Serial.println("[SD] New sensor_log.txt created.");
  } else {
    Serial.println("[SD] Failed to create new log.");
  }
}


void uploadAllSensorDataToFirebase() {
  ds2.requestTemperatures();
  float temperature_ds2 = ds2.getTempCByIndex(0);
  ds3.requestTemperatures();
  float temperature_ds3 = ds3.getTempCByIndex(0);

  float tempC2 = dht2.readTemperature();
  float humidity2 = dht2.readHumidity();
  float tempC3 = dht3.readTemperature();
  float humidity3 = dht3.readHumidity();
  float tempC4 = dht4.readTemperature();
  float humidity4 = dht4.readHumidity();

  float distance1 = readUltrasonicCM(US1_TRIG, US1_ECHO);
  float distance4 = readUltrasonicCM(US4_TRIG, US4_ECHO);

  float soil2Percent = getSoilMoisturePercentage(2960, 1231, analogRead(SOIL2));
  float soil3Percent = getSoilMoisturePercentage(3499, 1747, analogRead(SOIL3));
  float soil4Percent = getSoilMoisturePercentage(2968, 1260, analogRead(SOIL4));

  timeClient.update();
  time_t rawTime = timeClient.getEpochTime();
  struct tm *timeInfo = localtime(&rawTime);
  char dateBuffer[7], timeBuffer[7];
  strftime(dateBuffer, sizeof(dateBuffer), "%d%m%y", timeInfo);
  strftime(timeBuffer, sizeof(timeBuffer), "%H%M%S", timeInfo);
  String dateStr = String(dateBuffer);
  String timeStr = String(timeBuffer);

  Database.set<float>(aClient, "/Current_Sensor_Reading/temperature_ds2", temperature_ds2);
  Database.set<float>(aClient, "/Current_Sensor_Reading/temperature_ds3", temperature_ds3);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht2/Temperature", tempC2);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht2/Humidity", humidity2);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht3/Temperature", tempC3);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht3/Humidity", humidity3);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht4/Temperature", tempC4);
  Database.set<float>(aClient, "/Current_Sensor_Reading/dht4/Humidity", humidity4);
  Database.set<float>(aClient, "/Current_Sensor_Reading/Soil_Moisture2", soil2Percent);
  Database.set<float>(aClient, "/Current_Sensor_Reading/Soil_Moisture3", soil3Percent);
  Database.set<float>(aClient, "/Current_Sensor_Reading/Soil_Moisture4", soil4Percent);
  Database.set<float>(aClient, "/Current_Sensor_Reading/Distance1", distance1);
  Database.set<float>(aClient, "/Current_Sensor_Reading/Distance4", distance4);
  Database.set<String>(aClient, "/Current_Sensor_Reading/Current_Time", timeStr);
  Database.set<String>(aClient, "/Current_Sensor_Reading/Current_Date", dateStr);
}


void checkAndUpdateActuators() {
    Serial.println("[Firebase] Update triggered. Fetching actuator values...");

    // Chamber 1
    door1_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_1st/Door");

    // Chamber 2
    door2_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_2nd/Door");
    exhaust2_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_2nd/Exhaust");

    // Chamber 3
    door3_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_3rd/Door");
    exhaust3_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_3rd/Exhaust");
    valve3_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_3rd/Valve");
    heater3_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_3rd/Heater");
    heater_fan_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_3rd/Heater_Fan");
    // Chamber 4
    door4_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_4th/Door");
    exhaust4_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_4th/Exhaust");
    turning_state = Database.get<int>(aClient, "/Actuator_Control/Chamber_4th/Turning");
    
    // Optional: print values
    Serial.printf("Ch1 Door: %d | Ch2 Door: %d, Exhaust: %d, Valve: %d\n", door1_state, door2_state, exhaust2_state);
    Serial.printf("Ch3 Door: %d, Exhaust: %d, Valve: %d, Heater: %d\n", door3_state, exhaust3_state, valve3_state, heater3_state);
    Serial.printf("Ch4 Door: %d, Exhaust: %d, Turning: %d\n", door4_state, exhaust4_state, turning_state);

    // Clear the update flag
    //update = 0;
}

void rotateMotor(int direction, uint32_t nowSec) {
  // direction: 1 = stop/idle, 2 = forward, 3 = reverse
  // rotation_state: 0=IDLE, 1=DISABLE_WAIT, 2=CLEAR_WAIT, 3=PRESTART_WAIT, 4=RUNNING
  const uint32_t T_DISABLE = 2;  // seconds
  const uint32_t T_CLEAR   = 2;  // seconds
  const uint32_t T_PRE     = 2;  // seconds

  Serial.println("----");
  Serial.print("Requested direction: "); Serial.println(direction);
  Serial.print("nowSec: "); Serial.println(nowSec);

  auto disableDriver = [&](){
    digitalWrite(MOTOR_SWITCH, HIGH);
    logActuatorDataToSD("MOTOR_SWITCH", "HIGH");
    Serial.println("MOTOR_SWITCH = HIGH (motor disabled)");
  };
  auto enableDriver = [&](){
    digitalWrite(MOTOR_SWITCH, LOW);
    logActuatorDataToSD("MOTOR_SWITCH", "LOW");
    Serial.println("MOTOR_SWITCH = LOW (motor enabled)");
  };
  auto clearDirs = [&](){
    digitalWrite(MOTOR_FWD, HIGH);
    logActuatorDataToSD("MOTOR_FWD", "HIGH");
    digitalWrite(MOTOR_REV, HIGH);
    logActuatorDataToSD("MOTOR_REV", "HIGH");
    Serial.println("DIRS CLEARED: FWD=HIGH, REV=HIGH");
  };
  auto setFwd = [&](){
    digitalWrite(MOTOR_FWD, LOW);
    logActuatorDataToSD("MOTOR_FWD", "LOW");
    digitalWrite(MOTOR_REV, HIGH);
    logActuatorDataToSD("MOTOR_REV", "HIGH");
    Serial.println("MOTOR_FWD = LOW (forward), MOTOR_REV = HIGH");
  };
  auto setRev = [&](){
    digitalWrite(MOTOR_FWD, HIGH);
    logActuatorDataToSD("MOTOR_FWD", "HIGH");
    digitalWrite(MOTOR_REV, LOW);
    logActuatorDataToSD("MOTOR_REV", "LOW");
    Serial.println("MOTOR_FWD = HIGH (reverse), MOTOR_REV = LOW");
  };

  // If a STOP (1) arrives while running or mid-sequence: disable + clear and return to IDLE.
  if (direction == 1) {
    if (rotation_state == 0) {
      disableDriver();
      clearDirs();
      rotation_state = 0;
    }
    Serial.print("rotation_state: "); Serial.println(rotation_state);
    Serial.print("rotation_counter (sec): "); Serial.println(rotation_counter);
    return;
  }

  // Map 2/3 to a target
  enum Target { NONE, TO_FWD, TO_REV };
  Target target = (direction == 2) ? TO_FWD : (direction == 3) ? TO_REV : NONE;

  switch (rotation_state) {
    case 0: // IDLE → start sequence by disabling
      if (target != NONE) {
        disableDriver();
        rotation_counter = nowSec;
        rotation_state = 1; // DISABLE_WAIT
      }
      break;

    case 1: // wait after disable, then clear dirs
      if ((uint32_t)(nowSec - rotation_counter) >= T_DISABLE) {
        clearDirs();
        rotation_counter = nowSec;
        rotation_state = 2; // CLEAR_WAIT
      }
      break;

    case 2: // wait after clear, then set direction
      if ((uint32_t)(nowSec - rotation_counter) >= T_CLEAR) {
        if (target == TO_FWD) setFwd();
        else if (target == TO_REV) setRev();
        else { // command withdrawn
          clearDirs();
          rotation_state = 0;
          break;
        }
        rotation_counter = nowSec;
        rotation_state = 3; // PRESTART_WAIT
      }
      break;

    case 3: // wait before enabling
      if ((uint32_t)(nowSec - rotation_counter) >= T_PRE) {
        enableDriver();
        rotation_counter = nowSec;
        rotation_state = 4; // RUNNING
      }
      break;

    case 4: // RUNNING: stay enabled until direction becomes 1 (handled at top)
      // (optional) you can add a runtime watchdog here if needed.
      break;
  }

  Serial.print("rotation_state: "); Serial.println(rotation_state);
  Serial.print("rotation_counter (sec): "); Serial.println(rotation_counter);
}

// ---------- Grinder control (single function) ----------
// Hold button for HOLD_MS → runs motor for RUN_MS.
// Works with active-low or active-high drivers. Non-blocking, debounced.
