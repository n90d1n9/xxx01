import '../models/pos_touch_layout_profile_catalog.dart';
import 'touch_layout_profiles/coffee_counter_touch_layout_profile.dart';
import 'touch_layout_profiles/core_counter_touch_layout_profile.dart';
import 'touch_layout_profiles/grocery_scanner_touch_layout_profile.dart';
import 'touch_layout_profiles/kiosk_self_service_touch_layout_profile.dart';
import 'touch_layout_profiles/restaurant_service_touch_layout_profile.dart';
import 'touch_layout_profiles/retail_assisted_touch_layout_profile.dart';

export 'touch_layout_profiles/coffee_counter_touch_layout_profile.dart';
export 'touch_layout_profiles/core_counter_touch_layout_profile.dart';
export 'touch_layout_profiles/grocery_scanner_touch_layout_profile.dart';
export 'touch_layout_profiles/kiosk_self_service_touch_layout_profile.dart';
export 'touch_layout_profiles/restaurant_service_touch_layout_profile.dart';
export 'touch_layout_profiles/retail_assisted_touch_layout_profile.dart';

/// Default touch layout profiles shipped with the shared Kaysir POS runtime.
const defaultPOSTouchLayoutProfiles = [
  coreCounterTouchLayoutProfile,
  groceryScannerTouchLayoutProfile,
  coffeeCounterTouchLayoutProfile,
  restaurantServiceTouchLayoutProfile,
  retailAssistedTouchLayoutProfile,
  kioskSelfServiceTouchLayoutProfile,
];

/// Default catalog used by runtime packs that do not provide custom touch layouts.
const defaultPOSTouchLayoutProfileCatalog = POSTouchLayoutProfileCatalog(
  defaultProfileId: 'core_counter_touch',
  profiles: defaultPOSTouchLayoutProfiles,
);
