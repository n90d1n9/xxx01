import 'package:flutter/material.dart';

class IconPickerData {
  static const List<IconData> commonIcons = [
    Icons.person,
    Icons.email,
    Icons.phone,
    Icons.home,
    Icons.work,
    Icons.location_on,
    Icons.calendar_today,
    Icons.access_time,
    Icons.attach_money,
    Icons.credit_card,
    Icons.lock,
    Icons.vpn_key,
    Icons.search,
    Icons.bookmark,
    Icons.favorite,
    Icons.star,
    Icons.notifications,
    Icons.settings,
    Icons.help,
    Icons.info,
  ];

  static const Map<String, List<IconData>> categories = {
    'Common': [Icons.person, Icons.email, Icons.phone, Icons.lock],
    'Business': [
      Icons.work,
      Icons.business,
      Icons.attach_money,
      Icons.credit_card,
    ],
    'Location': [Icons.home, Icons.location_on, Icons.map, Icons.place],
    'Time': [
      Icons.calendar_today,
      Icons.access_time,
      Icons.schedule,
      Icons.timer,
    ],
  };
}
