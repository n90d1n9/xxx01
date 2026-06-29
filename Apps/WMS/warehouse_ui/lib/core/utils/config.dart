// General
const appName = 'Golok Apps';

// Caution! use your host IP instead of LOCALHOST
// because it not recognize on emulator
const baseURL = 'http://localhost';

// Authentication
const String tokenKey = 'auth_token';
const String token = "token";
const String refreshTokenKey = 'refresh_token';

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
  "application/x-www-form-urlencoded"
];
String contentType =
    contentTypes.isNotEmpty ? contentTypes[0] : "application/json";


// Icon Images
const String iconApp = 'assets/icons/ic_appicon.png';
const String imageLogin = 'assets/images/img_login.jpg';
const String imageSplash = 'assets/icons/logo-golok.png';
