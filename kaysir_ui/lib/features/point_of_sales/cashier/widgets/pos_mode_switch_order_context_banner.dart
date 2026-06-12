import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import 'pos_switch_order_context_banner.dart';

class POSModeSwitchOrderContextBanner extends StatelessWidget {
  final Order? order;

  const POSModeSwitchOrderContextBanner({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return POSSwitchOrderContextBanner(order: order);
  }
}
