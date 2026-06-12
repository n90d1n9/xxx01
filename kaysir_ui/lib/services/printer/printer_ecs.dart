/* import 'package:esc_pos_printer/esc_pos_printer.dart';

class PrinterHardwareService {
  static Future<void> print(String content) async {
    final printer = NetworkPrinter(PaperSize.mm80);
    final connected = await printer.connect('192.168.1.100', port: 9100);
    
    if (connected) {
      printer.text(content);
      printer.cut();
      printer.disconnect();
    }
  }
}
 */