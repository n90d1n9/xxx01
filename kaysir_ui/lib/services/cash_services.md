class CashDrawerService {
  static final CashDrawerService _instance = CashDrawerService._internal();
  factory CashDrawerService() => _instance;
  CashDrawerService._internal();

  SerialPort? _port;

  Future<void> connect(String portName) async {
    _port?.close();
    
    _port = SerialPort(portName);
    _port!.openWrite();
    
    _port!.config = SerialPortConfig()
      ..baudRate = 9600
      ..bits = 8
      ..stopBits = 1
      ..parity = 0;
  }

  Future<void> openDrawer() async {
    if (_port == null || !_port!.isOpen) {
      throw Exception('Cash drawer not connected');
    }

    // Standard ESC/POS command to open cash drawer
    final command = [0x1B, 0x70, 0x00, 0x19, 0xFA];
    _port!.write(Uint8List.fromList(command));
  }

  void dispose() {
    _port?.close();
  }
}
