import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_fulfillment_promise_policy.dart';

final ecommerceOrderFulfillmentPromisePolicyProvider =
    Provider<OrderFulfillmentPromisePolicy>(
      (ref) => const OrderFulfillmentPromisePolicy(),
    );

final ecommerceOrderFulfillmentPromisePolicyIssuesProvider =
    Provider<List<OrderFulfillmentPromisePolicyIssue>>(
      (ref) =>
          ref.watch(ecommerceOrderFulfillmentPromisePolicyProvider).validate(),
    );
