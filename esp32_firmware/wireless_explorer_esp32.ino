#include <WiFi.h>
#include <WebServer.h>

#include <BLEDevice.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

// Wi-Fi network created by the ESP32
const char* ssid = "WirelessExplorer-ESP32";
const char* password = "Explore123";

WebServer server(80);
BLEScan* bleScanner;

// Escape special characters so device names are valid JSON
String escapeJson(String value) {
  value.replace("\\", "\\\\");
  value.replace("\"", "\\\"");
  value.replace("\n", "\\n");
  value.replace("\r", "\\r");
  return value;
}

// Home page: check whether the ESP32 server is running
void handleHome() {
  server.send(
    200,
    "text/plain",
    "Wireless Explorer ESP32 is online!"
  );
}

// Scan for nearby Bluetooth Low Energy devices
void handleScan() {
  Serial.println("Starting BLE scan...");

 BLEScanResults* results = bleScanner->start(5, false);

  String json = "{\"devices\":[";

 int count = results->getCount();

  for (int i = 0; i < count; i++) {
   BLEAdvertisedDevice device = results->getDevice(i);

    if (i > 0) {
      json += ",";
    }

    String name = "Unnamed BLE device";

    if (device.haveName()) {
      name = String(device.getName().c_str());
    }

    String address = String(
      device.getAddress().toString().c_str()
    );

    int rssi = device.getRSSI();

    json += "{";
    json += "\"name\":\"" + escapeJson(name) + "\",";
    json += "\"address\":\"" + address + "\",";
    json += "\"rssi\":" + String(rssi);
    json += "}";
  }

  json += "]}";

  bleScanner->clearResults();

  server.send(200, "application/json", json);

  Serial.printf("Found %d BLE devices\n", count);
}

void setup() {
  Serial.begin(115200);

  // Start Wi-Fi access point
  WiFi.mode(WIFI_AP);

  WiFi.softAP(ssid, password);

  Serial.println();
  Serial.println("ESP32 Wi-Fi started");
  Serial.print("Network: ");
  Serial.println(ssid);
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.softAPIP());

  // Initialize Bluetooth scanner
  BLEDevice::init("");

  bleScanner = BLEDevice::getScan();
  bleScanner->setActiveScan(true);
  bleScanner->setInterval(100);
  bleScanner->setWindow(99);

  // Create HTTP endpoints
  server.on("/", HTTP_GET, handleHome);
  server.on("/scan", HTTP_GET, handleScan);

  server.begin();

  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}