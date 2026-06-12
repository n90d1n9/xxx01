// General
const appName = 'Kaysir';
const bool offlineMode = bool.fromEnvironment('OFFLINE_MODE');
const String demoProfileAsset = String.fromEnvironment(
  'DEMO_PROFILE_ASSET',
  defaultValue: 'assets/data/demo_profile.json',
);

// Caution! use your host IP instead of LOCALHOST
// because it not recognize on emulator
const baseURL = 'http://localhost';

// Authentication
const String tokenKey = 'auth_token';
const String refreshTokenKey = 'refresh_token';
const String isFirstTimeKey = 'isFirstTime';

// Database
String storeName = 'Golok';
const String dbName = 'golok.db';
const String dbPassword = 'YOUR_DB_PASSWORD'; // Store securely

// Fields
const fieldId = 'id';

// Timeout
const int timeoutReceive = 5000;
const int timeoutConnection = 5000;

// Layout
const defaultPadding = 16.0;
const sideMenuWidth = 230.0;

// Content Type
List<String> contentTypes = [
  "application/json",
  "application/xml",
  "application/x-www-form-urlencoded",
];
String contentType =
    contentTypes.isNotEmpty ? contentTypes[0] : "application/json";

// Icon Images
const String iconApp = 'assets/icons/ic_appicon.png';
const String imageLogin = 'assets/icons/logo-golok.png';
const String imageIcon = 'assets/icons/logo-golok.png';
