import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Restaurant-facing alias for shared cross-FnB attention signal categories.
typedef RestaurantAttentionSignalKind = FnbAttentionSignalKind;

/// Restaurant-facing alias for shared cross-FnB attention signals.
typedef RestaurantAttentionSignal = FnbAttentionSignal;

/// Restaurant-facing alias for shared ranked attention signal queues.
typedef RestaurantAttentionSignalQueue = FnbAttentionSignalQueue;

/// Backwards-compatible restaurant name for the shared FnB pressure status.
typedef RestaurantServiceStatus = FnbServiceStatus;

/// Restaurant-facing alias for shared structured service alert categories.
typedef RestaurantServiceAlertType = FnbServiceAlertType;

/// Restaurant-facing alias for shared structured service alerts.
typedef RestaurantServiceAlert = FnbServiceAlert;

/// Restaurant-facing alias for shared operational service alert entries.
typedef RestaurantServiceAlertEntry = FnbServiceAlertEntry;

/// Restaurant-facing alias for shared service alert lifecycle state.
typedef RestaurantServiceAlertLifecycle = FnbServiceAlertLifecycle;

/// Restaurant-facing alias for shared service alert lifecycle statuses.
typedef RestaurantServiceAlertLifecycleStatus = FnbServiceAlertLifecycleStatus;

/// Restaurant-facing alias for shared service alert lifecycle actions.
typedef RestaurantServiceAlertLifecycleAction = FnbServiceAlertLifecycleAction;

/// Restaurant-facing alias for shared service alert lifecycle audit records.
typedef RestaurantServiceAlertLifecycleEvent = FnbServiceAlertLifecycleEvent;

/// Restaurant-facing alias for shared operational service alert summaries.
typedef RestaurantServiceAlertSummary = FnbServiceAlertSummary;

/// Restaurant-facing alias for shared guest and service context.
typedef RestaurantServiceContext = FnbServiceContext;

/// Backwards-compatible restaurant name for the shared kitchen station model.
typedef RestaurantKitchenStation = FnbKitchenStation;

/// Backwards-compatible restaurant name for top kitchen station pressure.
typedef RestaurantKitchenPressureSignal = FnbKitchenStationPressureSignal;

/// Restaurant-facing alias for shared menu availability state.
typedef RestaurantMenuAvailability = FnbMenuAvailability;

/// Restaurant-facing alias for shared menu categories.
typedef RestaurantMenuCategory = FnbMenuCategory;

/// Restaurant-facing alias for shared sellable menu items.
typedef RestaurantMenuItem = FnbMenuItem;

/// Restaurant-facing alias for shared menu recipe readiness.
typedef RestaurantMenuRecipeReadiness = FnbMenuRecipeReadiness;

/// Restaurant-facing alias for shared menu recipe readiness issues.
typedef RestaurantMenuRecipeReadinessIssue = FnbMenuRecipeReadinessIssue;

/// Restaurant-facing alias for shared menu books.
typedef RestaurantMenu = FnbMenu;

/// Restaurant-facing alias for shared recipe production records.
typedef RestaurantRecipe = FnbRecipe;

/// Restaurant-facing alias for shared recipe ingredient records.
typedef RestaurantRecipeIngredient = FnbRecipeIngredient;

/// Restaurant-facing alias for shared dietary and allergen tags.
typedef RestaurantDietaryTag = FnbDietaryTag;
