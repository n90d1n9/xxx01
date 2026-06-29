import 'csinode_driver.dart';

class CSINodeSpec {
  final List<CSINodeDriver> drivers;
  CSINodeSpec({required this.drivers});
  factory CSINodeSpec.fromJson(Map<String, dynamic> json) {
    return CSINodeSpec(
      drivers:
          (json['drivers'] as List)
              .map((e) => CSINodeDriver.fromJson(e))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'drivers': drivers.map((e) => e.toJson()).toList()};
  }
}
