import 'package:flutter/material.dart';



class AppsRoutes {
  AppsRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/commerce/home';
  static const String cart = '/commerce/cart';
  static const String chat = '/commerce/chat';
  static const String checkout = '/commerce/checkout';
  static const String payment = '/commerce/payment';
  static const String invoice = '/commerce/invoice';
  static const String help = '/commerce/help';
  static const String wishlist = '/commerce/whishlist';
  static const String voucher = '/commerce/voucher';
  static const String shop = '/commerce/shop';
  static const String settings = '/commerce/settings';
  static const String search = '/commerce/search';
  static const String promotion = '/commerce/promotion';
  static const String product = '/commerce/product';
  static const String order = '/commerce/order';
  static const String games = '/commerce/games';
  static const String error = '/commerce/error';
  static const String loyalty = '/commerce/loyalty';
  static const String live = '/commerce/live';
  

  static final routes = <String, WidgetBuilder>{
    /* splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomePage(), */
    //chat: (BuildContext context) => ChatWA(),
    //transport: (BuildContext context) => TransportSplash(),
   // payment: (BuildContext context) => PaymentPage(),
    /* profile: (BuildContext context) => ProfilePage(),
    readbook: (BuildContext context) => ReadBookPage(), */
  };
}
