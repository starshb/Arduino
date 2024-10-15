#include <SoftwareSerial.h>
#include <MD_Parola.h>
#include <MD_MAX72XX.h>
#include <SPI.h>

#define HARDWARE_TYPE MD_MAX72XX::FC16_HW
#define MAX_DEVICES 4 // 8x32 매트릭스이므로 8x8 모듈이 4개 필요

#define CLK_PIN 13
#define DATA_PIN 11
#define CS_PIN 10

// Bluetooth 모듈 TX 연결: 아두이노 D2, RX 연결: 아두이노 D3
SoftwareSerial bluetooth(2, 3); // RX, TX

MD_Parola myDisplay = MD_Parola(HARDWARE_TYPE, CS_PIN, MAX_DEVICES);
char message[100] = "Hello"; // 기본 문자열

void setup() {
Serial.begin(9600);
bluetooth.begin(9600); // Bluetooth 시리얼 시작
myDisplay.begin();
myDisplay.setIntensity(0); // 밝기 설정 (0~15)
myDisplay.displayClear();

Serial.println("Enter a message to display:"); // 시리얼 모니터에 출력
}

void loop() {
// Bluetooth 모듈에서 데이터 수신
if (bluetooth.available() > 0) {
int len = bluetooth.readBytesUntil('\n', message, sizeof(message) - 1); // 블루투스로부터 메시지 수신
message[len] = '\0'; // 문자열 종료 문자 추가
myDisplay.displayClear();
myDisplay.displayText(message, PA_CENTER, 100, 1000, PA_SCROLL_LEFT, PA_SCROLL_LEFT);
Serial.print("Received message: ");
Serial.println(message); // 수신된 메시지를 시리얼 모니터에 출력
}

if (myDisplay.displayAnimate()) {
myDisplay.displayReset(); // 애니메이션이 끝나면 반복
}
}
