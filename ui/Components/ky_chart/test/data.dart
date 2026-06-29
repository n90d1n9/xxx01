
  import 'package:flutter/material.dart';

final List<String> years = ['2012', '2013', '2014', '2015', '2016'];
  final List<Map<String, dynamic>> seriesData = [
    {
      'name': 'Forest',
      'color': Colors.green,
      'data': [320, 332, 301, 334, 390],
    },
    {
      'name': 'Steppe',
      'color': Colors.brown,
      'data': [220, 182, 191, 234, 290],
    },
    {
      'name': 'Desert',
      'color': Colors.orange,
      'data': [150, 232, 201, 154, 190],
    },
    {
      'name': 'Wetland',
      'color': Colors.blue,
      'data': [98, 77, 101, 99, 40],
    },
  ];


const option = {
  "tooltip": {
    "trigger": 'axis',
    "axisPointer": {
      "type": 'shadow'
    }
  },
  "legend": {
    "data": ['Profit', 'Expenses', 'Income']
  },
  "grid": {
    "left": '3%',
    "right": '4%',
    "bottom": '3%',
    "containLabel": true
  },
  "xAxis": [
    {
      "type": 'value'
    }
  ],
  "yAxis": [
    {
      "type": 'category',
      "axisTick": {
        "show": false
      },
      "data": ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    }
  ],
  "series": [
    {
      "name": 'Profit',
      "type": 'bar',
      "label": {
        "show": true,
        "position": 'inside'
      },
      "emphasis": {
        "focus": 'series'
      },
      "data": [200, 170, 240, 244, 200, 220, 210]
    },
    {
      "name": 'Income',
      "type": 'bar',
      "stack": 'Total',
      "label": {
        "show": true
      },
      "emphasis": {
        "focus": 'series'
      },
      "data": [320, 302, 341, 374, 390, 450, 420]
    },
    {
      "name": 'Expenses',
      "type": 'bar',
      "stack": 'Total',
      "label": {
        "show": true,
        "position": 'left'
      },
      "emphasis": {
        "focus": 'series'
      },
      "data": [-120, -132, -101, -134, -190, -230, -210]
    }
  ]
};