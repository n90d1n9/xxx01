import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';

const savedWorkspaceDeliveryToday = OrderSavedWorkspace(
  id: 'saved_delivery_today',
  label: 'Delivery / Today',
  description: 'Morning courier note',
  isDescriptionCustom: true,
  filter: OrderFilter(channelId: 'delivery_app'),
  sortMode: OrderSortMode.newest,
);

const savedWorkspacePinnedDeliveryToday = OrderSavedWorkspace(
  id: 'saved_delivery_today',
  label: 'Delivery / Today',
  description: 'Morning courier note',
  isDescriptionCustom: true,
  filter: OrderFilter(channelId: 'delivery_app'),
  sortMode: OrderSortMode.newest,
  isPinned: true,
);

const savedWorkspacePickupPriority = OrderSavedWorkspace(
  id: 'saved_pickup_priority',
  label: 'Pickup priority',
  description: 'Pinned pickup exceptions',
  filter: OrderFilter(status: 'exception'),
  sortMode: OrderSortMode.attention,
);

const savedWorkspacePinnedPickupPriority = OrderSavedWorkspace(
  id: 'saved_pickup_priority',
  label: 'Pickup priority',
  description: 'Pinned pickup exceptions',
  filter: OrderFilter(status: 'exception'),
  sortMode: OrderSortMode.attention,
  isPinned: true,
);

const savedWorkspaceWebOverdue = OrderSavedWorkspace(
  id: 'saved_web_overdue',
  label: 'Web overdue',
  description: 'Website escalations',
  filter: OrderFilter(channelId: 'web_store'),
  sortMode: OrderSortMode.oldest,
);

const savedWorkspaceWebOverdueCustomNote = OrderSavedWorkspace(
  id: 'saved_web_overdue',
  label: 'Web overdue',
  description: 'Website escalations',
  isDescriptionCustom: true,
  filter: OrderFilter(channelId: 'web_store'),
  sortMode: OrderSortMode.oldest,
);

const savedWorkspaceManagerFixtures = [
  savedWorkspaceDeliveryToday,
  savedWorkspacePinnedPickupPriority,
  savedWorkspaceWebOverdue,
];

const savedWorkspaceManagerUnsortedFixtures = [
  savedWorkspaceWebOverdue,
  savedWorkspacePinnedPickupPriority,
  savedWorkspaceDeliveryToday,
];
