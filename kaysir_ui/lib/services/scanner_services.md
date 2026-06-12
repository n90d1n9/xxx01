import 'dart:async';
import 'package:serial_port_win32/serial_port_win32.dart';

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  StreamController<String>? _controller;
  SerialPort? _port;

  Future<List<String>> getAvailablePorts() async {
    return SerialPort.getAvailablePorts();
  }

  Future<void> connect(String portName) async {
    _port?.close();
    _controller?.close();

    _port = SerialPort(portName);
    _port!.open(); //.openReadWrite();

    _controller = StreamController<String>.broadcast();

    _port!.config =
        SerialPortConfig()
          ..baudRate = 9600
          ..bits = 8
          ..stopBits = 1
          ..parity = 0;

    _port!.read().listen((data) {
      final code = String.fromCharCodes(data).trim();
      if (code.isNotEmpty) {
        _controller!.add(code);
      }
    });
  }

  Stream<String>? get scanStream => _controller?.stream;

  void dispose() {
    _port?.close();
    _controller?.close();
  }
}
