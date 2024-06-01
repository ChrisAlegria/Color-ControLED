#include <BluetoothSerial.h>
BluetoothSerial BT; // Instancia de la clase Bluetooth

// Puertos GPIO 15, 2 y 4
int redLed = 21, greenLed = 19, blueLed = 18;
int redColor = 0, greenColor = 0, blueColor = 0;

// Inicialización de Bluetooth y puertos
void setup() {
  Serial.begin(9600);
  BT.begin("ESP32");

  pinMode(redLed, OUTPUT);
  pinMode(greenLed, OUTPUT);
  pinMode(blueLed, OUTPUT);

  // Inicialización de LED
  analogWrite(redLed, 0);
  analogWrite(greenLed, 0);
  analogWrite(blueLed, 0);
}

void loop() {
  if (BT.available()) {
    // Leer los valores RGB desde el Bluetooth
    String data = BT.readStringUntil('\n');
    // Parsear y aplicar los valores RGB
    parseRGB(data); 
  }
  delay(10);
}

void parseRGB(String data) {
  int commaIndex1 = data.indexOf(',');
  int commaIndex2 = data.lastIndexOf(',');

  if (commaIndex1 > 0 && commaIndex2 > commaIndex1) {
    redColor = data.substring(0, commaIndex1).toInt();
    greenColor = data.substring(commaIndex1 + 1, commaIndex2).toInt();
    blueColor = data.substring(commaIndex2 + 1).toInt();

    Serial.print(redColor);
    Serial.print(", ");
    Serial.print(greenColor);
    Serial.print(", ");
    Serial.println(blueColor);

    analogWrite(redLed, redColor);
    analogWrite(greenLed, greenColor);
    analogWrite(blueLed, blueColor);
  } else {
    Serial.println("Valor RGB incorrecto");
  }
}

