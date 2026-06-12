import '../models/restaurant_models.dart';

/// Demo shift tasks used by the Kaysir restaurant workspace.
const restaurantDemoShiftTasks = [
  RestaurantShiftTask(
    id: 'table-turn',
    title: 'Reset tables 7, 9, and 12 before the next wave',
    owner: 'Floor team',
    dueLabel: 'Due in 8m',
    progress: .64,
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantShiftTask(
    id: 'rendang-par',
    title: 'Confirm rendang par level and update menu availability',
    owner: 'Sous chef',
    dueLabel: 'Due now',
    progress: .38,
    status: RestaurantServiceStatus.critical,
  ),
  RestaurantShiftTask(
    id: 'private-course',
    title: 'Pace private room third course with grill station',
    owner: 'Event captain',
    dueLabel: 'Due in 14m',
    progress: .72,
    status: RestaurantServiceStatus.busy,
  ),
];
