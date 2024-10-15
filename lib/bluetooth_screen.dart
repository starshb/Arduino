import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';  // Uint8List를 사용하기 위해 필요한 import

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  final TextEditingController _textController = TextEditingController();  // TextField 컨트롤러
  bool isConnecting = true;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // 블루투스 장치 스캔 및 연결 함수
  void startScan() async {
    List<BluetoothDevice> devices = [];
    // 주변의 페어링된 기기들을 스캔
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      print("Found devices: ${devices.map((d) => d.name).toList()}");
    } catch (e) {
      print("Error scanning devices: $e");
      return;
    }

    // 원하는 장치(HC-05)를 찾고 연결 시도
    for (var device in devices) {
      if (device.name == 'HC-05') {
        print("Connecting to device: ${device.name}");
        await connectToDevice(device);
        break;
      }
    }
  }

  // 블루투스 장치에 연결하는 함수
  connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connectedDevice = device;
        isConnected = true;
        isConnecting = false;
      });
      print("Connected to device: ${device.name}");
    } catch (e) {
      print("Failed to connect: $e");
      setState(() {
        isConnecting = false;
      });
    }
  }

  // 블루투스 장치에 데이터를 보내는 함수
  void sendData(String data) async {
    if (connection != null && connection!.isConnected) {
      List<int> bytes = (data + '\n').codeUnits;  // 데이터를 전송할 때 개행 문자 포함
      print("Sending data: $data");  // 디버그용으로 출력
      connection!.output.add(Uint8List.fromList(bytes));  // Bluetooth를 통해 데이터 전송
      await connection!.output.allSent;
    } else {
      print("No connection to the device.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Data Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '문구를 입력해주세요 (최대 5자).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLength: 5,  // 최대 5자
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '입력해주세요',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? () {
                if (_textController.text.isNotEmpty) {
                  sendData(_textController.text);  // 입력된 데이터 전송
                }
              } : null,  // 장치가 연결된 상태에서만 버튼 활성화
              child: Text('데이터 전송'),
            ),
            if (!isConnected)
              Text(
                isConnecting ? '블루투스 장치에 연결 중...' : '블루투스 장치가 연결되지 않았습니다.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
