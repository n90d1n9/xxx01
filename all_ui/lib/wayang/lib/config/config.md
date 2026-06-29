import 'package:flutter/foundation.dart';

// General
const appName = 'Maktab I\'lamy';

// Caution! use your host IP instead of LOCALHOST
// because it not recognize on emulator

//const baseUrl = 'http://localhost:7100';
const String host = 'api.mikuone.com';
const baseUrl = 'https://$host';

//final wsBaseUrl =
//    baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
//const wsBaseUrl = 'ws://localhost:7101';
const wsBaseUrl = 'ws://$host';
//const baseUrlContent = 'https://strapi.mikuone.com';

// Web-specific API URL to handle CORS
String get webBaseUrl {
  if (kIsWeb) {
    // Use direct API URL - CORS should be configured on backend
    return baseUrl;
  }
  return baseUrl;
}

// Authentication
const tokenKey = 'accessToken';
const tokenKeyContent = 'auth_token_content';
const refreshTokenKey = 'refresh_token';
const isFirstTimeKey = 'isFirstTime';
const finishedGuideKey = 'finishedGuideKey';

// Database
const storeName = 'one_ummah';
const dbName = 'one_ummah.db';

// Fields
const fieldId = 'id';

// Timeout
const int timeoutReceive = 12000;
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
const iconApp = 'assets/icons/ic_appicon.png';
const imageLogin = 'assets/icons/one-rec-b@2x.png';
const imageIcon = 'assets/icons/one-rec-b@2x.png';

const strapiApiKey =
    'e97a47b7b03d73888dd0a0ecc560649abf6ea5c34ce9a481c8ce36824895a0017ae715325b58a68832b61ae289e3d9e0a9f393da9993729830f94e24b99ec9f4a72587f3daa927d4e7ea09c7c7e5845391f4d3fc8ab2fd7360bd0a66da90af7894d6423493c42dd398458092f77ed187f03e5f8880c43db0893350622be82141';

const gApiKey = ''; //'AIzaSyDsi5CwpHGvjxkH1I9EmSDNQL0OMIVtPgQ';

const fontSize = 10.0;
